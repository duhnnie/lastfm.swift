import Foundation
import SwiftRestClient

internal protocol Requester {

    func build(params: [String: String], secure: Bool) -> URL

    func makeGetRequest(
        url: URL,
        headers: [String: String]?,
        onCompletion: @escaping (Result<Data, LastFMError>) -> Void
    )

    func getDataAndParse<T: Decodable>(
        url: URL,
        headers: SwiftRestClient.Headers?,
        onCompletion: @escaping LastFM.OnCompletion<T>
    )

}