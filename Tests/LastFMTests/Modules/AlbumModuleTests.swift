import XCTest
@testable import LastFM

class AlbumModuleTests: XCTestCase {

    private static let lastFM = LastFM(
        apiKey: Constants.API_KEY,
        apiSecret: Constants.API_SECRET
    )

    private var instance: AlbumModule!
    private var apiClient = APIClientMock()

    override func setUpWithError() throws {
        instance = AlbumModule(
            instance: Self.lastFM,
            requester: RequestUtils(apiClient: apiClient)
        )
    }

    override func tearDownWithError() throws {
        apiClient.clearMock()
    }

    // getTopTracks
    func test_getInfo_withUsername() throws {
        let jsonURL = Bundle.module.url(
            forResource: "Resources/album.getInfo_withUsername",
            withExtension: "json"
        )!

        let fakeDate = try Data(contentsOf: jsonURL)
        let expectation = expectation(description: "Waiting for getInfo with username")

        let params = AlbumInfoParams(
            artist: "Various Artists",
            album: "Some Album Title",
            username: "pepe"
        )

        apiClient.data = fakeDate
        apiClient.response = Constants.RESPONSE_200_OK

        instance.getInfo(params: params) { result in
            switch (result) {
            case .success(let albumInfo):
                XCTAssertEqual(albumInfo.artist, "Various Artists")
                XCTAssertEqual(albumInfo.mbid, "some-artist-mbid")

                XCTAssertEqual(albumInfo.tags.count, 3)
                XCTAssertEqual(albumInfo.tags[0].name, "industrial rock")
                XCTAssertEqual(albumInfo.tags[0].url.absoluteString, "https://www.last.fm/tag/industrial+rock")
                XCTAssertEqual(albumInfo.tags[1].name, "industrial")
                XCTAssertEqual(albumInfo.tags[1].url.absoluteString, "https://www.last.fm/tag/industrial")
                XCTAssertEqual(albumInfo.tags[2].name, "rock")
                XCTAssertEqual(albumInfo.tags[2].url.absoluteString, "https://www.last.fm/tag/rock")

                XCTAssertEqual(albumInfo.name, "Some Album Title")
                XCTAssertEqual(albumInfo.userPlaycount, 832)

                XCTAssertEqual(
                    albumInfo.images.small?.absoluteString,
                    "https://images.com/artist/small.png"
                )

                XCTAssertEqual(
                    albumInfo.images.medium?.absoluteString,
                    "https://images.com/artist/medium.png"
                )

                XCTAssertEqual(
                    albumInfo.images.large?.absoluteString,
                    "https://images.com/artist/large.png"
                )

                XCTAssertEqual(
                    albumInfo.images.extraLarge?.absoluteString,
                    "https://images.com/artist/extralarge.png"
                )

                XCTAssertEqual(
                    albumInfo.images.mega?.absoluteString,
                    "https://images.com/artist/mega.png"
                )

                XCTAssertEqual(albumInfo.tracks?.count, 5)

                XCTAssertEqual(albumInfo.tracks?[0].streamable, .noStreamable)
                XCTAssertEqual(albumInfo.tracks?[0].duration, 307)
                XCTAssertEqual(albumInfo.tracks?[0].url.absoluteString, "http://tracks.com/track-1")
                XCTAssertEqual(albumInfo.tracks?[0].name, "Track 1")
                XCTAssertEqual(albumInfo.tracks?[0].trackNumber, 1)
                XCTAssertEqual(albumInfo.tracks?[0].artist.url.absoluteString, "https://artists.com/artist-1")
                XCTAssertEqual(albumInfo.tracks?[0].artist.name, "Artist 1")
                XCTAssertEqual(albumInfo.tracks?[0].artist.mbid, "artist-1-mbid")

                XCTAssertEqual(albumInfo.tracks?[1].streamable, .noStreamable)
                XCTAssertEqual(albumInfo.tracks?[1].duration, 222)
                XCTAssertEqual(albumInfo.tracks?[1].url.absoluteString, "http://tracks.com/track-2")
                XCTAssertEqual(albumInfo.tracks?[1].name, "Track 2")
                XCTAssertEqual(albumInfo.tracks?[1].trackNumber, 2)
                XCTAssertEqual(albumInfo.tracks?[1].artist.url.absoluteString, "https://artists.com/artist-2")
                XCTAssertEqual(albumInfo.tracks?[1].artist.name, "Artist 2")
                XCTAssertEqual(albumInfo.tracks?[1].artist.mbid, "artist-2-mbid")

                XCTAssertEqual(albumInfo.tracks?[2].streamable, .noStreamable)
                XCTAssertEqual(albumInfo.tracks?[2].duration, 187)
                XCTAssertEqual(albumInfo.tracks?[2].url.absoluteString, "http://tracks.com/track-3")
                XCTAssertEqual(albumInfo.tracks?[2].name, "Track 3")
                XCTAssertEqual(albumInfo.tracks?[2].trackNumber, 3)
                XCTAssertEqual(albumInfo.tracks?[2].artist.url.absoluteString, "https://artists.com/artist-3")
                XCTAssertEqual(albumInfo.tracks?[2].artist.name, "Artist 3")
                XCTAssertEqual(albumInfo.tracks?[2].artist.mbid, "artist-3-mbid")

                XCTAssertEqual(albumInfo.tracks?[3].streamable, .noStreamable)
                XCTAssertEqual(albumInfo.tracks?[3].duration, 211)
                XCTAssertEqual(albumInfo.tracks?[3].url.absoluteString, "http://tracks.com/track-4")
                XCTAssertEqual(albumInfo.tracks?[3].name, "Track 4")
                XCTAssertEqual(albumInfo.tracks?[3].trackNumber, 4)
                XCTAssertEqual(albumInfo.tracks?[3].artist.url.absoluteString, "https://artists.com/artist-4")
                XCTAssertEqual(albumInfo.tracks?[3].artist.name, "Artist 4")
                XCTAssertEqual(albumInfo.tracks?[3].artist.mbid, "artist-4-mbid")

                XCTAssertEqual(albumInfo.tracks?[4].streamable, .noStreamable)
                XCTAssertEqual(albumInfo.tracks?[4].duration, 222)
                XCTAssertEqual(albumInfo.tracks?[4].url.absoluteString, "http://tracks.com/track-5")
                XCTAssertEqual(albumInfo.tracks?[4].name, "Track 5")
                XCTAssertEqual(albumInfo.tracks?[4].trackNumber, 5)
                XCTAssertEqual(albumInfo.tracks?[4].artist.url.absoluteString, "https://artists.com/artist-5")
                XCTAssertEqual(albumInfo.tracks?[4].artist.name, "Artist 5")
                XCTAssertEqual(albumInfo.tracks?[4].artist.mbid, "artist-5-mbid")

                XCTAssertEqual(albumInfo.listeners, 803026)
                XCTAssertEqual(albumInfo.playcount, 20522460)

                XCTAssertEqual(
                    albumInfo.url.absoluteString,
                    "https://albums.com/some-album"
                )

                let dateComponents = DateComponents(
                    calendar: Calendar.current,
                    timeZone: TimeZone(secondsFromGMT: 0),
                    year: 2023,
                    month: 6,
                    day: 6,
                    hour: 6,
                    minute: 30
                )

                XCTAssertEqual(
                    albumInfo.wiki?.published,
                    Calendar.current.date(from: dateComponents)!
                )

                XCTAssertEqual(albumInfo.wiki?.summary, "Some summary.")
                XCTAssertEqual(albumInfo.wiki?.content, "Some content.")

            case .failure(let error):
                XCTFail("Expected to succeed, but it failed with error: \(error.localizedDescription)")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 3)
        XCTAssertEqual(apiClient.getCalls.count, 1)
        XCTAssertEqual(apiClient.getCalls[0].headers, nil)

        XCTAssertTrue(
            Util.areSameURL(
                apiClient.getCalls[0].url.absoluteString,
                "http://ws.audioscrobbler.com/2.0?method=album.getinfo&artist=Various%20Artists&username=pepe&format=json&album=Some%20Album%20Title&api_key=someAPIKey&autocorrect=1"
            )
        )
    }

    func test_getInfoByMBID_withUsername() throws {
        let jsonURL = Bundle.module.url(
            forResource: "Resources/album.getInfo_withUsername",
            withExtension: "json"
        )!

        let fakeDate = try Data(contentsOf: jsonURL)
        let expectation = expectation(description: "Waiting for getInfo with username")

        let params = AlbumInfoByMBIDParams(
            mbid: "some-artist-mbid",
            autocorrect: false,
            username: "pepe",
            lang: "pt"
        )

        apiClient.data = fakeDate
        apiClient.response = Constants.RESPONSE_200_OK

        instance.getInfo(params: params) { result in
            switch (result) {
            case .success(_):
                break
            case .failure(let error):
                XCTFail("Expected to succeed, but it failed with error: \(error.localizedDescription)")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 3)
        XCTAssertEqual(apiClient.getCalls.count, 1)
        XCTAssertEqual(apiClient.getCalls[0].headers, nil)

        XCTAssertTrue(
            Util.areSameURL(
                apiClient.getCalls[0].url.absoluteString,
                "http://ws.audioscrobbler.com/2.0?method=album.getinfo&mbid=some-artist-mbid&username=pepe&format=json&lang=pt&autocorrect=0&api_key=someAPIKey"
            )
        )
    }

    func test_getInfo_noUsername() throws {
        let jsonURL = Bundle.module.url(
            forResource: "Resources/album.getInfo_noUsername",
            withExtension: "json"
        )!

        let fakeDate = try Data(contentsOf: jsonURL)
        let expectation = expectation(description: "Waiting for getInfo with username")

        let params = AlbumInfoParams(
            artist: "Some Artist",
            album: "Some Album Title",
            autocorrect: false,
            lang: "fr"
        )

        apiClient.data = fakeDate
        apiClient.response = Constants.RESPONSE_200_OK

        instance.getInfo(params: params) { result in
            switch (result) {
            case .success(let albumInfo):
                XCTAssertNil(albumInfo.userPlaycount)
            case .failure(let error):
                XCTFail("Expected to succeed, but it failed with error: \(error.localizedDescription)")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 3)
        XCTAssertEqual(apiClient.getCalls.count, 1)
        XCTAssertEqual(apiClient.getCalls[0].headers, nil)

        XCTAssertTrue(
            Util.areSameURL(
                apiClient.getCalls[0].url.absoluteString,
                "http://ws.audioscrobbler.com/2.0?method=album.getinfo&artist=Some%20Artist&album=Some%20Album%20Title&format=json&lang=fr&autocorrect=0&api_key=someAPIKey"
            )
        )
    }

    func test_getInfoByMBID_noUsername() throws {
        let jsonURL = Bundle.module.url(
            forResource: "Resources/album.getInfo_noUsername",
            withExtension: "json"
        )!

        let fakeDate = try Data(contentsOf: jsonURL)
        let expectation = expectation(description: "Waiting for getInfo with username")

        let params = AlbumInfoByMBIDParams(
            mbid: "some-artist-mbid",
            autocorrect: true,
            lang: "pt"
        )

        apiClient.data = fakeDate
        apiClient.response = Constants.RESPONSE_200_OK

        instance.getInfo(params: params) { result in
            switch (result) {
            case .success(let albumInfo):
                XCTAssertNil(albumInfo.userPlaycount)
            case .failure(let error):
                XCTFail("Expected to succeed, but it failed with error: \(error.localizedDescription)")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 3)
        XCTAssertEqual(apiClient.getCalls.count, 1)
        XCTAssertEqual(apiClient.getCalls[0].headers, nil)

        XCTAssertTrue(
            Util.areSameURL(
                apiClient.getCalls[0].url.absoluteString,
                "http://ws.audioscrobbler.com/2.0?method=album.getinfo&mbid=some-artist-mbid&format=json&lang=pt&autocorrect=1&api_key=someAPIKey"
            )
        )
    }

}