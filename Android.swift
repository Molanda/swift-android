import ScadeKit
import JNI

class Android {
  class Object: JavaParameterConvertible {
    private var this: JavaObject? = nil

    class var type: String {
      get {
        return "java/lang/Object"
      }
    }

    class var javaClass: JavaClass {
      get {
        return jni.FindClass(name: self.type)
      }
    }

    class var asJNIParameterString: String {
      get {
        return "L\(self.type);"
      }
    }

    var isNull: Bool {
      get {
        return self.this == nil
      }
    }

    required init(for this: JavaObject?) {
      if let this = this {
        self.this = jni.NewGlobalRef(this)!
      }
    }

    convenience init(with javaArgs: [JavaParameterConvertible] = [], as type: String) {
      let jniObject = try! JNIObject(type, arguments: javaArgs)
      self.init(for: jniObject.instance)
    }

    deinit {
      if let this = self.this {
        jni.DeleteGlobalRef(globalRef: this)
      }
    }

    func toJavaParameter() -> JavaParameter {
      return JavaParameter(object: this)
    }

    func toJavaObject() -> JavaObject {
      return self.this!
    }

    static func fromJavaObject(object: JavaObject) throws -> Self {
      return self.init(for: object)
    }

    static func fromStaticMethod(calling methodID: JavaMethodID, on javaClass: JavaClass, args: [JavaParameter]) throws -> Self {
      let javaObject = try jni.CallStaticObjectMethod(methodID, on: javaClass, parameters: args)
      return self.init(for: javaObject)
    }

    static func fromStaticField(_ fieldID: JavaFieldID, of javaClass: JavaClass) throws -> Self {
      let javaObject = try jni.GetStaticObjectField(of: javaClass, id: fieldID)
      return self.init(for: javaObject)
    }

    static func fromField(_ fieldID: JavaFieldID, on javaObject: JavaObject) throws -> Self {
      let javaObject = try jni.GetObjectField(of: javaObject, id: fieldID)
      return self.init(for: javaObject)
    }

    static func fromMethod(calling methodID: JavaMethodID, on object: JavaObject, args: [JavaParameter]) throws -> Self {
      let javaObject = try jni.CallObjectMethod(methodID, on: object, parameters: args)
      return self.init(for: javaObject)
    }

    fileprivate static func call(_ methodName: String, with javaArgs: [JavaParameterConvertible] = []) {
      return try! jni.callStatic(methodName, on: self.javaClass, arguments: javaArgs) as Void
    }

    @discardableResult fileprivate static func call<T: JavaParameterConvertible>(_ methodName: String, with javaArgs: [JavaParameterConvertible] = []) -> T {
      return try! jni.callStatic(methodName, on: self.javaClass, arguments: javaArgs)
    }

    fileprivate func call(_ methodName: String, with javaArgs: [JavaParameterConvertible] = []) {
      return try! jni.call(methodName, on: self.this!, arguments: javaArgs) as Void
    }

    @discardableResult fileprivate func call<T: JavaParameterConvertible>(_ methodName: String, with javaArgs: [JavaParameterConvertible] = []) -> T {
      return try! jni.call(methodName, on: self.this!, arguments: javaArgs)
    }

    fileprivate func get<T: JavaParameterConvertible>(_ fieldName: String) -> T {
      let javaClass = try! jni.GetObjectClass(obj: self.this!)
      let javaArgs: [JavaParameterConvertible] = [fieldName]
      let javaField = try! jni.call("getField", on: javaClass, arguments: javaArgs, returningObjectType: "java/lang/reflect/Field")
      let javaFieldId = jni.FromReflectedField(field: javaField!)
      return try! T.fromField(javaFieldId, on: self.this!)
    }
  }

  class Array: JavaParameterConvertible {
    private var this: JavaObject? = nil

    class var type: String {
      get {
        return "?"
      }
    }

    class var javaClass: JavaClass {
      get {
        return jni.FindClass(name: self.type)
      }
    }

    class var asJNIParameterString: String {
      get {
        return "[\(self.type)"
      }
    }

    var isNull: Bool {
      get {
        return self.this == nil
      }
    }

    required init(for this: JavaObject?) {
      if let this = this {
        self.this = jni.NewGlobalRef(this)!
      }
    }

    deinit {
      if let this = self.this {
        jni.DeleteGlobalRef(globalRef: this)
      }
    }

    func toJavaParameter() -> JavaParameter {
      return JavaParameter(object: this)
    }

    func toJavaObject() -> JavaObject {
      return self.this!
    }

    static func fromJavaObject(object: JavaObject) throws -> Self {
      return self.init(for: object)
    }

    static func fromStaticMethod(calling methodID: JavaMethodID, on javaClass: JavaClass, args: [JavaParameter]) throws -> Self {
      let javaObject = try jni.CallStaticObjectMethod(methodID, on: javaClass, parameters: args)
      return self.init(for: javaObject)
    }

    static func fromStaticField(_ fieldID: JavaFieldID, of javaClass: JavaClass) throws -> Self {
      let javaObject = try jni.GetStaticObjectField(of: javaClass, id: fieldID)
      return self.init(for: javaObject)
    }

    static func fromField(_ fieldID: JavaFieldID, on javaObject: JavaObject) throws -> Self {
      let javaObject = try jni.GetObjectField(of: javaObject, id: fieldID)
      return self.init(for: javaObject)
    }

    static func fromMethod(calling methodID: JavaMethodID, on object: JavaObject, args: [JavaParameter]) throws -> Self {
      let javaObject = try jni.CallObjectMethod(methodID, on: object, parameters: args)
      return self.init(for: javaObject)
    }
  }

  class ByteArray: Array {
    override class var type: String {
      get {
        return "B"
      }
    }

    var bytes: [UInt8] {
      get {
        return jni.GetByteArrayRegion(array: self.toJavaObject()).map(UInt8.init)
      }
    }

    convenience init(bytes: [UInt8]?) {
      var array: JavaArray? = nil
      if let bytes = bytes {
        array = jni.NewByteArray(count: bytes.count)
        if let array = array {
          jni.SetByteArrayRegion(array: array, from: bytes.map(Int8.init))
        }
      }
      self.init(for: array)
    }
  }

  class CharArray: Array {
    override class var type: String {
      get {
        return "C"
      }
    }

    convenience init(value: String?) {
      var array: JavaArray? = nil
      if let value = value {
        let bytes: [UInt8] = Swift.Array(value.utf8)
        array = jni.NewByteArray(count: bytes.count)
        if let array = array {
          jni.SetByteArrayRegion(array: array, from: bytes.map(Int8.init))
        }
      }
      self.init(for: array)
    }
  }

  class BigInteger: Object {
    override class var type: String {
      get {
        return "java/math/BigInteger"
      }
    }

    convenience init(value: String) {
      let javaArgs: [JavaParameterConvertible] = [value]
      self.init(with: javaArgs, as: BigInteger.type)
    }
  }

  class Date: Object {
    override class var type: String {
      get {
        return "java/util/Date"
      }
    }
  }

  class Calendar: Object {
    override class var type: String {
      get {
        return "java/util/Calendar"
      }
    }

    enum Field: Int {
      case Era = 0
      case Year = 1
      case Month = 2
      case WeekOfYear = 3
      case WeekOfMonth = 4
      case DayOfMonth = 5
      case DayOfYear = 6
      case DayOfWeek = 7
      case DayOfWeekInMonth = 8
      case AmPm = 9
      case Hour = 10
      case HourOfDay = 11
      case Minute = 12
      case Second = 13
      case Millisecond = 14
    }

    static func getInstance() -> Calendar {
      return self.call("getInstance") as Calendar
    }

    func add(field: Field, amount: Int) {
      let javaArgs: [JavaParameterConvertible] = [Int32(field.rawValue), Int32(amount)]
      self.call("add", with: javaArgs)
    }

    func clear() {
      self.call("clear")
    }

    func clear(field: Field) {
      let javaArgs: [JavaParameterConvertible] = [Int32(field.rawValue)]
      self.call("clear", with: javaArgs)
    }

    func getTime() -> Date {
      return self.call("getTime") as Date
    }
  }

  class ActivityThread: Object {
    override class var type: String {
      get {
        return "android/app/ActivityThread"
      }
    }

    static func currentActivityThread() -> ActivityThread {
      return self.call("currentActivityThread") as ActivityThread
    }

    func getApplication() -> Application {
      return self.call("getApplication") as Application
    }
  }

  class Application: Object {
    override class var type: String {
      get {
        return "android/app/Application"
      }
    }

    func getApplicationContext() -> Context {
      return self.call("getApplicationContext") as Context
    }
  }

  class Context: Object {
    override class var type: String {
      get {
        return "android/content/Context"
      }
    }

    enum Mode: Int {
      case Private = 0
    }

    func getSharedPreferences(name: String, mode: Mode) -> SharedPreferences {
      let javaArgs: [JavaParameterConvertible] = [name, Int32(mode.rawValue)]
      return self.call("getSharedPreferences", with: javaArgs) as SharedPreferences
    }

    func getPackageName() -> String {
      return self.call("getPackageName") as String
    }

    func getPackageManager() -> PackageManager {
      return self.call("getPackageManager") as PackageManager
    }
  }

  class SharedPreferences: Object {
    override class var type: String {
      get {
        return "android/content/SharedPreferences"
      }
    }

    class Editor: Object {
      override class var type: String {
        get {
          return "android/content/SharedPreferences$Editor"
        }
      }

      func apply() {
        self.call("apply")
      }

      func remove(key: String) {
        let javaArgs: [JavaParameterConvertible] = [key]
        let _ = self.call("putString", with: javaArgs) as Editor
      }

      func putString(key: String, value: String) {
        let javaArgs: [JavaParameterConvertible] = [key, value]
        let _ = self.call("putString", with: javaArgs) as Editor
      }

      func putBoolean(key: String, value: Bool) {
        let javaArgs: [JavaParameterConvertible] = [key, value]
        let _ = self.call("putBoolean", with: javaArgs) as Editor
      }

      func putInt(key: String, value: Int) {
        let javaArgs: [JavaParameterConvertible] = [key, Int32(value)]
        let _ = self.call("putInt", with: javaArgs) as Editor
      }

      func putLong(key: String, value: Int64) {
        let javaArgs: [JavaParameterConvertible] = [key, value]
        let _ = self.call("putLong", with: javaArgs) as Editor
      }
    }

    func edit() -> Editor {
      return self.call("edit") as Editor
    }

    func contains(key: String) -> Bool {
      let javaArgs: [JavaParameterConvertible] = [key]
      return self.call("contains", with: javaArgs) as Bool
    }

    func getString(key: String, default defValue: String?) -> String? {
      if defValue == nil && self.contains(key: key) == false {
        return nil
      }
      let javaArgs: [JavaParameterConvertible] = [key, defValue ?? ""]
      return self.call("getString", with: javaArgs) as String
    }

    func getBoolean(key: String, default defValue: Bool) -> Bool {
      let javaArgs: [JavaParameterConvertible] = [key, defValue]
      return self.call("getBoolean", with: javaArgs) as Bool
    }

    func getInt(key: String, default defValue: Int) -> Int {
      let javaArgs: [JavaParameterConvertible] = [key, Int32(defValue)]
      return Int(self.call("getInt", with: javaArgs) as Int32)
    }

    func getLong(key: String, default defValue: Int64) -> Int64 {
      let javaArgs: [JavaParameterConvertible] = [key, defValue]
      return self.call("getLong", with: javaArgs) as Int64
    }
  }

  class PackageManager: Object {
    override class var type: String {
      get {
        return "android/content/pm/PackageManager"
      }
    }

    struct Flags: OptionSet {
      let rawValue: Int

      static let GetMetaData = Flags(rawValue: 1 << 7)
    }

    func getPackageInfo(name: String, flags: Flags) -> PackageInfo {
      let javaArgs: [JavaParameterConvertible] = [name, Int32(flags.rawValue)]
      return self.call("getPackageInfo", with: javaArgs) as PackageInfo
    }
  }

  class PackageInfo: Object {
    override class var type: String {
      get {
        return "android/content/pm/PackageInfo"
      }
    }

    var versionName: String {
      get {
        return self.get("versionName") as String
      }
    }
  }

  class KeyProperties {
    enum Algorithm: String {
      case RSA = "RSA"
    }

    struct Purpose: OptionSet {
      let rawValue: Int

      static let Encrypt = Purpose(rawValue: 1 << 0)
      static let Decrypt = Purpose(rawValue: 1 << 1)
    }

    struct Digest: OptionSet {
      let rawValue: Int

      var strings: [String] {
        get {
          var strings = [String]()
          if self.isEmpty == true {
            strings.append("NONE")
          }
          if self.contains(.SHA1) == true {
            strings.append("SHA-1")
          }
          if self.contains(.SHA224) == true {
            strings.append("SHA-224")
          }
          if self.contains(.SHA256) == true {
            strings.append("SHA-256")
          }
          if self.contains(.SHA384) == true {
            strings.append("SHA-384")
          }
          if self.contains(.SHA512) == true {
            strings.append("SHA-512")
          }
          return strings
        }
      }

      static let SHA1 = Digest(rawValue: 1 << 0)
      static let SHA224 = Digest(rawValue: 1 << 1)
      static let SHA256 = Digest(rawValue: 1 << 2)
      static let SHA384 = Digest(rawValue: 1 << 3)
      static let SHA512 = Digest(rawValue: 1 << 4)
    }

    struct EncryptionPadding: OptionSet {
      let rawValue: Int

      var strings: [String] {
        get {
          var strings = [String]()
          if self.isEmpty == true {
            strings.append("NoPadding")
          }
          if self.contains(.PKCS7) == true {
            strings.append("PKCS7Padding")
          }
          if self.contains(.OAEP) == true {
            strings.append("OAEPPadding")
          }
          if self.contains(.PKCS1) == true {
            strings.append("PKCS1Padding")
          }
          return strings
        }
      }

      static let PKCS7 = EncryptionPadding(rawValue: 1 << 0)
      static let OAEP = EncryptionPadding(rawValue: 1 << 1)
      static let PKCS1 = EncryptionPadding(rawValue: 1 << 2)
    }
  }

  class X500Principal: Object {
    override class var type: String {
      get {
        return "javax/security/auth/x500/X500Principal"
      }
    }

    convenience init(name: String) {
      let javaArgs: [JavaParameterConvertible] = [name]
      self.init(with: javaArgs, as: X500Principal.type)
    }
  }

  class KeySpec: Object {
    override class var type: String {
      get {
        return "java/security/spec/KeySpec"
      }
    }
  }

  class X509EncodedKeySpec: KeySpec {
    override class var type: String {
      get {
        return "java/security/spec/X509EncodedKeySpec"
      }
    }

    convenience init(encodedKey: [UInt8]) {
      let javaArgs: [JavaParameterConvertible] = [ByteArray(bytes: encodedKey)]
      self.init(with: javaArgs, as: X509EncodedKeySpec.type)
    }
  }

  class KeyPair: Object {
    override class var type: String {
      get {
        return "java/security/KeyPair"
      }
    }
  }

  class KeyPairGenerator: Object {
    override class var type: String {
      get {
        return "java/security/KeyPairGenerator"
      }
    }

    static func getInstance(algorithm: KeyProperties.Algorithm, provider: String) -> KeyPairGenerator {
      let javaArgs: [JavaParameterConvertible] = [algorithm.rawValue, provider]
      return self.call("getInstance", with: javaArgs) as KeyPairGenerator
    }

    func initialize(params: AlgorithmParameterSpec) {
      let javaArgs: [JavaParameterConvertible] = [AlgorithmParameterSpec(for: params.toJavaObject())]
      self.call("initialize", with: javaArgs)
    }

    @discardableResult func generateKeyPair() -> KeyPair {
      return self.call("generateKeyPair") as KeyPair
    }
  }

  class AlgorithmParameterSpec: Object {
    override class var type: String {
      get {
        return "java/security/spec/AlgorithmParameterSpec"
      }
    }
  }

  class KeyGenParameterSpec: AlgorithmParameterSpec {
    override class var type: String {
      get {
        return "android/security/keystore/KeyGenParameterSpec"
      }
    }

    class Builder: Object {
      override class var type: String {
        get {
          return "android/security/keystore/KeyGenParameterSpec$Builder"
        }
      }

      convenience init(_ keystoreAlias: String, purposes: KeyProperties.Purpose) {
        let javaArgs: [JavaParameterConvertible] = [keystoreAlias, Int32(purposes.rawValue)]
        self.init(with: javaArgs, as: Builder.type)
      }

      @discardableResult func setDigests(_ digests: KeyProperties.Digest) -> Builder {
        let javaArgs: [JavaParameterConvertible] = digests.strings
        return self.call("setDigests", with: javaArgs) as Builder
      }

      @discardableResult func setEncryptionPaddings(_ paddings: KeyProperties.EncryptionPadding) -> Builder {
        let javaArgs: [JavaParameterConvertible] = paddings.strings
        return self.call("setEncryptionPaddings", with: javaArgs) as Builder
      }

      func build() -> KeyGenParameterSpec {
        return self.call("build") as KeyGenParameterSpec
      }
    }
  }

  class KeyPairGeneratorSpec: AlgorithmParameterSpec {
    override class var type: String {
      get {
        return "android/security/KeyPairGeneratorSpec"
      }
    }

    class Builder: Object {
      override class var type: String {
        get {
          return "android/security/KeyPairGeneratorSpec$Builder"
        }
      }

      convenience init(context: Context) {
        let javaArgs: [JavaParameterConvertible] = [context]
        self.init(with: javaArgs, as: Builder.type)
      }

      @discardableResult func setAlias(_ alias: String) -> Builder {
        let javaArgs: [JavaParameterConvertible] = [alias]
        return self.call("setAlias", with: javaArgs) as Builder
      }

      @discardableResult func setEncryptionRequired() -> Builder {
        return self.call("setEncryptionRequired") as Builder
      }

      @discardableResult func setStartDate(_ startDate: Date) -> Builder {
        let javaArgs: [JavaParameterConvertible] = [startDate]
        return self.call("setStartDate", with: javaArgs) as Builder
      }

      @discardableResult func setEndDate(_ endDate: Date) -> Builder {
        let javaArgs: [JavaParameterConvertible] = [endDate]
        return self.call("setEndDate", with: javaArgs) as Builder
      }

      @discardableResult func setKeySize(_ keySize: Int) -> Builder {
        let javaArgs: [JavaParameterConvertible] = [Int32(keySize)]
        return self.call("setKeySize", with: javaArgs) as Builder
      }

      @discardableResult func setKeyType(_ keyType: String) -> Builder {
        let javaArgs: [JavaParameterConvertible] = [keyType]
        return self.call("setKeyType", with: javaArgs) as Builder
      }

      @discardableResult func setSerialNumber(_ serialNumber: BigInteger) -> Builder {
        let javaArgs: [JavaParameterConvertible] = [serialNumber]
        return self.call("setSerialNumber", with: javaArgs) as Builder
      }

      @discardableResult func setSubject(_ subject: X500Principal) -> Builder {
        let javaArgs: [JavaParameterConvertible] = [subject]
        return self.call("setSubject", with: javaArgs) as Builder
      }

      func build() -> KeyPairGeneratorSpec {
        return self.call("build") as KeyPairGeneratorSpec
      }
    }
  }

  class Key: Object {
    override class var type: String {
      get {
        return "java/security/Key"
      }
    }

    func toString() -> String {
      return self.call("toString") as String
    }

    func getEncoded() -> ByteArray {
      return self.call("getEncoded") as ByteArray
    }
  }

  class PublicKey: Key {
    override class var type: String {
      get {
        return "java/security/PublicKey"
      }
    }
  }

  class PrivateKey: Key {
    override class var type: String {
      get {
        return "java/security/PrivateKey"
      }
    }
  }

  class Certificate: Object {
    override class var type: String {
      get {
        return "java/security/cert/Certificate"
      }
    }

    func getPublicKey() -> PublicKey {
      return self.call("getPublicKey") as PublicKey
    }
  }

  class KeyStore: Object {
    override class var type: String {
      get {
        return "java/security/KeyStore"
      }
    }

    class LoadStoreParameter: Object {
      override class var type: String {
        get {
          return "java/security/KeyStore$LoadStoreParameter"
        }
      }
    }

    static func getInstance(type: String) -> KeyStore {
      let javaArgs: [JavaParameterConvertible] = [type]
      return self.call("getInstance", with: javaArgs) as KeyStore
    }

    static func getDefaultType() -> String {
      return self.call("getDefaultType") as String
    }

    func load(param: LoadStoreParameter?) {
      let javaArgs: [JavaParameterConvertible] = [param ?? LoadStoreParameter(for: nil)]
      return self.call("load", with: javaArgs)
    }

    func containsAlias(_ alias: String) -> Bool {
      let javaArgs: [JavaParameterConvertible] = [alias]
      return self.call("containsAlias", with: javaArgs) as Bool
    }

    func deleteEntry(alias: String) {
      let javaArgs: [JavaParameterConvertible] = [alias]
      return self.call("deleteEntry", with: javaArgs)
    }

    func getKey(alias: String, password: String?) -> PrivateKey? {
      let javaArgs: [JavaParameterConvertible] = [alias, CharArray(value: password)]
      let key = self.call("getKey", with: javaArgs) as Key
      if key.isNull == true {
        return nil
      }
      return PrivateKey(for: key.toJavaObject())
    }

    func getCertificate(alias: String) -> Certificate? {
      let javaArgs: [JavaParameterConvertible] = [alias]
      let certificate = self.call("getCertificate", with: javaArgs) as Certificate
      if certificate.isNull == true {
        return nil
      }
      return certificate
    }
  }

  class KeyFactory: Object {
    override class var type: String {
      get {
        return "java/security/KeyFactory"
      }
    }

    static func getInstance(algorithm: String) -> KeyFactory {
      let javaArgs: [JavaParameterConvertible] = [algorithm]
      return self.call("getInstance", with: javaArgs) as KeyFactory
    }

    func generatePublic(keySpec: KeySpec) -> PublicKey {
      let javaArgs: [JavaParameterConvertible] = [KeySpec(for: keySpec.toJavaObject())]
      return self.call("generatePublic", with: javaArgs) as PublicKey
    }
  }

  class Cipher: Object {
    override class var type: String {
      get {
        return "javax/crypto/Cipher"
      }
    }

    enum Mode: Int {
      case Encrypt = 1
      case Decrypt = 2
      case Wrap = 3
      case Unwrap = 4
    }

    static func getInstance(transformation: String) -> Cipher {
      let javaArgs: [JavaParameterConvertible] = [transformation]
      return self.call("getInstance", with: javaArgs) as Cipher
    }

    static func getInstance(transformation: String, provider: String) -> Cipher {
      let javaArgs: [JavaParameterConvertible] = [transformation, provider]
      return self.call("getInstance", with: javaArgs) as Cipher
    }

    func `init`(opmode: Mode, key: Key) {
      let javaArgs: [JavaParameterConvertible] = [Int32(opmode.rawValue), Key(for: key.toJavaObject())]
      return self.call("init", with: javaArgs)
    }

    func doFinal(input: [UInt8], inputOffset: Int, inputLen: Int, output: inout [UInt8]) -> Int {
      let inputArray = ByteArray(bytes: input)
      let outputArray = ByteArray(bytes: output)
      let javaArgs: [JavaParameterConvertible] = [inputArray, Int32(inputOffset), Int32(inputLen), outputArray]
      let outputLen = Int(self.call("doFinal", with: javaArgs) as Int32)
      let outputBytes = outputArray.bytes
      for i in 0..<outputLen {
        output[i] = outputBytes[i]
      }
      return outputLen
    }
  }

  static var context: Context = {
    let javaThread = ActivityThread.currentActivityThread()
    let javaApp = javaThread.getApplication()
    return javaApp.getApplicationContext()
  }()
}

