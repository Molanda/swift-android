import ScadeKit

typealias NSObject = SwiftFoundation.NSObject

extension DispatchGroup {
  func notify(queue: DispatchQueue, execute work: @escaping () -> Void) {
    self.notify(qos: .unspecified, flags: [], queue: DispatchQueue.global(qos: .background)) {
      DispatchQueue.main.async {
        work()
      }
    }
  }
}

class UserDefaults {
  private var defaults = [String: Any]()

  static var standard: UserDefaults = {
    return UserDefaults()
  }()

  private var preferences: Android.SharedPreferences {
    get {
      return Android.context.getSharedPreferences(name: "UserDefaults", mode: .Private)
    }
  }

  func synchronize() {
  }

  func register(defaults: [String: Any]) {
    self.defaults = defaults
  }

  func set(_ value: String?, forKey key: String) {
    let editor = self.preferences.edit()
    if let value = value {
      editor.putString(key: key, value: value)
    } else {
      editor.remove(key: key)
    }
    editor.apply()
  }

  func set(_ value: Bool, forKey key: String) {
    let editor = self.preferences.edit()
    editor.putBoolean(key: key, value: value)
    editor.apply()
  }

  func set(_ value: Int, forKey key: String) {
    let editor = self.preferences.edit()
    editor.putInt(key: key, value: value)
    editor.apply()
  }

  func string(forKey key: String) -> String? {
    return self.preferences.getString(key: key, default: self.defaults[key] as? String)
  }

  func bool(forKey key: String) -> Bool {
    return self.preferences.getBoolean(key: key, default: self.defaults[key] as? Bool ?? false)
  }

  func integer(forKey key: String) -> Int {
    return self.preferences.getInt(key: key, default: self.defaults[key] as? Int ?? 0)
  }
}
