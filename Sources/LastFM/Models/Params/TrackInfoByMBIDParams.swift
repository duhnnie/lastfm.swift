import Foundation

public struct TrackInfoByMBIDParams: Params {

    public var mbid: String
    public var username: String?
    public var autocorrect: Bool

    public init(mbid: String, username: String? = nil, autocorrect: Bool = true) {
        self.mbid = mbid
        self.username = username
        self.autocorrect = autocorrect
    }

    internal func toDictionary() -> Dictionary<String, String> {
        var dict = [
            "mbid": self.mbid,
            "autocorrect": self.autocorrect ? "1" : "0"
        ]

        if let username = username {
            dict["username"] = username
        }

        return dict
    }

}
