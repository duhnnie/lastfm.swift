import XCTest
@testable import LastFM

class GeoModuleTests: XCTestCase {

    private static let lastFM = LastFM(
        apiKey: Constants.API_KEY,
        apiSecret: Constants.API_SECRET
    )

    private var instance: GeoModule!
    private var apiClient = APIClientMock()

    override func setUpWithError() throws {
        instance = GeoModule(
            instance: Self.lastFM,
            requester: RequestUtils(apiClient: apiClient)
        )
    }

    override func tearDownWithError() throws {
        apiClient.clearMock()
    }

    // getTopTracks

    func test_getTopTracks_success() throws {
        let jsonURL = Bundle.module.url(
            forResource: "Resources/geo.getTopTracks",
            withExtension: "json"
        )!

        let fakeData = try Data(contentsOf: jsonURL)
        let expectation = expectation(description: "waiting for successful getTopTracks")

        let params = GeoTopTracksParams(
            country: "Bolivia",
            location: "somelocation",
            limit: 5,
            page: 1
        )

        let expectedEntity = try JSONDecoder().decode(
            CollectionPage<GeoTopTrack>.self,
            from: fakeData
        )

        apiClient.data = fakeData
        apiClient.response = Constants.RESPONSE_200_OK

        instance.getTopTracks(params: params) { result in
            switch(result) {
            case .success(let entity):
                XCTAssertEqual(entity, expectedEntity)
            case .failure(let error):
                XCTFail("Expected to succeed, but it failed with error \(error)")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 3)
        XCTAssertEqual(apiClient.getCalls.count, 1)
        XCTAssertNil(apiClient.getCalls[0].headers)

        XCTAssertTrue(
            Util.areSameURL(
                apiClient.getCalls[0].url.absoluteString,
                "http://ws.audioscrobbler.com/2.0/?api_key=\(Constants.API_KEY)&format=json&method=geo.gettoptracks&country=\(params.country)&location=\(params.location!)&limit=\(params.limit)&page=\(params.page)")
        )
    }

    func test_getTopTracks_failure()  throws {
        let jsonURL = Bundle.module.url(
            forResource: "Resources/geo.getTopTracksBadParams",
            withExtension: "json"
        )!

        let fakeData = try Data(contentsOf: jsonURL)
        let params = GeoTopTracksParams(country: "bo")
        let expectation = expectation(description: "waiting for getTopTracks to fail")

        apiClient.data = fakeData
        // In real life, for some unknown reason, lastfm
        // returns a 200 even if country param is wrong.
        // But here we using a 400 bad request for testing porpuses.
        apiClient.response = Constants.RESPONSE_400_BAD_REQUEST

        instance.getTopTracks(params: params) { result in
            switch (result) {
            case .success(_):
                XCTFail("Expected to fail, but it succedeed")
            case .failure(let error):
                switch (error) {

                case .LastFMServiceError(let errorType, let message):
                    XCTAssertEqual(errorType, .InvalidParameters)
                    XCTAssertEqual(message, "country param required")
                default:
                    XCTFail("Expected to be LastFMServiceErrorType.InvalidParameters")
                }
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 3)
    }

    func test_getTopArtists_success() throws {
        let jsonURL = Bundle.module.url(
            forResource: "Resources/geo.getTopArtists",
            withExtension: "json"
        )!

        let fakeData = try Data(contentsOf: jsonURL)
        let expectation = expectation(description: "Waiting for getTopArtists")
        let params = GeoTopArtistsParams(country: "australia", limit: 5, page: 1)

        apiClient.data = fakeData
        apiClient.response = Constants.RESPONSE_200_OK

        instance.getTopArtists(params: params) { result in
            switch(result) {
            case .success(let topArtists):
                XCTAssertEqual(topArtists.pagination.page, 1)
                XCTAssertEqual(topArtists.pagination.perPage, 5)
                XCTAssertEqual(topArtists.pagination.total, 1297046)
                XCTAssertEqual(topArtists.pagination.totalPages, 259410)

                XCTAssertEqual(topArtists.items.count, 5)
                XCTAssertEqual(topArtists.items[0].name, "Radiohead")
                XCTAssertEqual(topArtists.items[0].listeners, 6214938)
                XCTAssertEqual(topArtists.items[0].mbid, "a74b1b7f-71a5-4011-9441-d0b5e4122711")
                XCTAssertEqual(topArtists.items[0].url.absoluteString, "https://www.last.fm/music/Radiohead")
                XCTAssertEqual(topArtists.items[0].streamable, false)

                XCTAssertEqual(
                    topArtists.items[0].images.small!.absoluteString,
                    "https://lastfm.freetls.fastly.net/i/u/34s/2a96cbd8b46e442fc41c2b86b821562f.png"
                )

                XCTAssertEqual(
                    topArtists.items[0].images.medium!.absoluteString,
                    "https://lastfm.freetls.fastly.net/i/u/64s/2a96cbd8b46e442fc41c2b86b821562f.png"
                )

                XCTAssertEqual(
                    topArtists.items[0].images.large!.absoluteString,
                    "https://lastfm.freetls.fastly.net/i/u/174s/2a96cbd8b46e442fc41c2b86b821562f.png"
                )

                XCTAssertEqual(
                    topArtists.items[0].images.extraLarge!.absoluteString,
                    "https://lastfm.freetls.fastly.net/i/u/300x300/2a96cbd8b46e442fc41c2b86b821562f.png"
                )

                XCTAssertEqual(
                    topArtists.items[0].images.mega!.absoluteString,
                    "https://lastfm.freetls.fastly.net/i/u/300x300/2a96cbd8b46e442fc41c2b86b821562f.png"
                )
            case .failure(let error):
                XCTFail("It was expected to succeed, but it failed with error \(error.localizedDescription)")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 3)
    }
}
