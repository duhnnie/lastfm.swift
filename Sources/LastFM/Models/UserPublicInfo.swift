import Foundation

public struct UserPublicInfo: Decodable {

    public let name: String
    public let url: URL
    public let country: String
    public let playlists: UInt
    public let playcount: UInt
    public let images: LastFMImages
    public let registered: Date
    public let realname: String
    public let subscriber: Bool
    public let bootstrap: Bool
    public let type: String

    private enum CodingKeys: String, CodingKey {
        case name
        case url
        case country
        case playlists
        case playcount
        case images = "image"
        case registered
        case realname
        case subscriber
        case bootstrap
        case type
    }

}
