import XCTest
@testable import LastFM

class UserTests: XCTestCase {

    private static let lastFM = LastFM(
        apiKey: Constants.API_KEY,
        apiSecret: Constants.API_SECRET
    )

    private var instance: UserModule!
    private var apiClientMock = APIClientMock()

    override func setUpWithError() throws {
        instance = UserModule(
            parent: Self.lastFM,
            secure: true,
            requester: RequestUtils(apiClient: apiClientMock)
        )
    }

    override func tearDownWithError() throws {
        apiClientMock.clearMock()
    }
    
    func test_invalidAPIKey() async throws {
        let jsonURL = Bundle.module.url(
            forResource: "Resources/errorInvalidAPIKey",
            withExtension: "json"
        )!

        let params = UserTopItemsParams(user: "andrea")

        apiClientMock.data = try Data(contentsOf: jsonURL)
        apiClientMock.response = Constants.RESPONSE_403_FORBIDDEN
        
        do {
            let _ = try await instance.getTopTracks(params: params)
            XCTFail("Expected to fail, but it succeeded")
        } catch LastFMError.LastFMServiceError(let lastfmErrorType, let message) {
            XCTAssertEqual(lastfmErrorType, .InvalidAPIKey)
            XCTAssertEqual(message, "Invalid API key - You must be granted a valid key by last.fm")
        } catch {
            XCTFail("Expected to be a LastFMError.InvalidAPIKey, but we got \(error) instead")
        }
    }

    func test_invalidAPIKey() throws {
        let jsonURL = Bundle.module.url(
            forResource: "Resources/errorInvalidAPIKey",
            withExtension: "json"
        )!

        let params = UserTopItemsParams(user: "andrea")
        let expectation = expectation(description: "waiting for request with invalid api key")

        apiClientMock.data = try Data(contentsOf: jsonURL)
        apiClientMock.response = Constants.RESPONSE_403_FORBIDDEN

        instance.getTopTracks(params: params) { result in
            switch(result) {
            case .success(_):
                XCTFail("Expected to fail, but it succeeded")
            case .failure(let error):
                switch (error) {

                case .LastFMServiceError(let lastfmErrorType, let message):
                    XCTAssertEqual(lastfmErrorType, .InvalidAPIKey)
                    XCTAssertEqual(message, "Invalid API key - You must be granted a valid key by last.fm")
                default:
                    XCTFail("Expected to be a LastFMError.InvalidAPIKey, but we got \(error) instead")
                }
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 3)
    }
    
    func test_withInvalidPageNumber() async throws {
        let jsonURL = Bundle.module.url(
            forResource: "Resources/errorInvalidParameters",
            withExtension: "json"
        )!

        let params = RecentTracksParams(user: "stephanie")

        apiClientMock.data = try Data(contentsOf: jsonURL)
        apiClientMock.response = Constants.RESPONSE_400_BAD_REQUEST
        
        do {
            let _ = try await instance.getRecentTracks(params: params)
            
            XCTFail("Expected to fail, but it succeeded instead")
        } catch LastFMError.LastFMServiceError(let lastfmErrorType, let message) {
            XCTAssertEqual(lastfmErrorType, .InvalidParameters)
            XCTAssertEqual(message, "page param out of bounds (1-1000000)")
        } catch {
            XCTFail("Expected to be a LastFMError.InvaluParameters error, but we got \(error)")
        }
    }

    func test_withInvalidPageNumber() throws {
        let jsonURL = Bundle.module.url(
            forResource: "Resources/errorInvalidParameters",
            withExtension: "json"
        )!

        let params = RecentTracksParams(user: "stephanie")
        let expectation = expectation(description: "waiting for invalid parameters response")

        apiClientMock.data = try Data(contentsOf: jsonURL)
        apiClientMock.response = Constants.RESPONSE_400_BAD_REQUEST

        instance.getRecentTracks(params: params) { result in
            switch(result) {
            case .success(_):
                XCTFail("Expected to fail, but it succeeded instead")
            case .failure(let error):
                switch(error) {
                case .LastFMServiceError(let lastfmErrorType, let message):
                    XCTAssertEqual(lastfmErrorType, .InvalidParameters)
                    XCTAssertEqual(message, "page param out of bounds (1-1000000)")
                default:
                    XCTFail("Expected to be a LastFMError.InvaluParameters error, but we got \(error)")
                }
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 3)
    }

    // getRecentTracks

    fileprivate func validateUserRecentTracksSuccessResponse(_ recentTracks: (CollectionPage<RecentTrack>)) {
        XCTAssertEqual(recentTracks.items.count, 3)
        XCTAssertEqual(recentTracks.pagination.total, 60)
        XCTAssertEqual(recentTracks.pagination.totalPages, 30)
        XCTAssertEqual(recentTracks.pagination.page, 1)
        XCTAssertEqual(recentTracks.pagination.perPage, 2)
        
        XCTAssertEqual(recentTracks.items[0].artist.mbid, "95e1ead9-4d31-4808-a7ac-32c3614c116b")
        XCTAssertEqual(recentTracks.items[0].artist.name, "The Killers")
        XCTAssertEqual(recentTracks.items[0].streamable, false)
        
        XCTAssertEqual(
            recentTracks.items[0].image.small?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/34s/d83c5d906703a8c8042285d0902d9cf4.png"
        )
        
        XCTAssertEqual(
            recentTracks.items[0].image.medium?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/64s/d83c5d906703a8c8042285d0902d9cf4.png"
        )
        
        XCTAssertEqual(
            recentTracks.items[0].image.large?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/174s/d83c5d906703a8c8042285d0902d9cf4.png"
        )
        
        XCTAssertEqual(
            recentTracks.items[0].image.extraLarge?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/300x300/d83c5d906703a8c8042285d0902d9cf4.png"
        )
        
        XCTAssertNil(recentTracks.items[0].image.mega)
        XCTAssertEqual(recentTracks.items[0].mbid, "")
        XCTAssertEqual(recentTracks.items[0].album.mbid, "044ef3c8-6b25-4fac-8f88-5c982df90a72")
        XCTAssertEqual(recentTracks.items[0].album.name, "Hot Fuss")
        XCTAssertEqual(recentTracks.items[0].name, "Smile Like You Mean It")
        XCTAssertEqual(recentTracks.items[0].url.absoluteString, "https://www.last.fm/music/The+Killers/_/Smile+Like+You+Mean+It")
        XCTAssertEqual(recentTracks.items[0].nowPlaying, true)
        XCTAssertNil(recentTracks.items[0].date)
        
        XCTAssertEqual(recentTracks.items[1].artist.mbid, "e6de1f3b-6484-491c-88dd-6d619f142abc")
        XCTAssertEqual(recentTracks.items[1].artist.name, "Hans Zimmer")
        XCTAssertEqual(recentTracks.items[1].streamable, false)
        
        XCTAssertEqual(
            recentTracks.items[1].image.small?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/34s/e27d852480cc782e8c0eb0e253245dc3.jpg"
        )
        
        XCTAssertEqual(
            recentTracks.items[1].image.medium?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/64s/e27d852480cc782e8c0eb0e253245dc3.jpg"
        )
        
        XCTAssertEqual(
            recentTracks.items[1].image.large?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/174s/e27d852480cc782e8c0eb0e253245dc3.jpg"
        )
        
        XCTAssertEqual(
            recentTracks.items[1].image.extraLarge?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/300x300/e27d852480cc782e8c0eb0e253245dc3.jpg"
        )
        
        XCTAssertNil(recentTracks.items[1].image.mega)
        XCTAssertEqual(recentTracks.items[1].mbid, "0268842d-7e27-4443-af74-a8bba51b08cd")
        XCTAssertEqual(recentTracks.items[1].album.mbid, "20074beb-380c-4da5-8dcd-e1eb063f78ce")
        XCTAssertEqual(recentTracks.items[1].album.name, "Interstellar")
        XCTAssertEqual(recentTracks.items[1].name, "Mountains")
        XCTAssertEqual(recentTracks.items[1].url.absoluteString, "https://www.last.fm/music/Hans+Zimmer/_/Mountains")
        XCTAssertEqual(recentTracks.items[1].nowPlaying, false)
        
        let dateComponents = DateComponents(
            calendar: Calendar.current,
            timeZone: TimeZone(secondsFromGMT: 0),
            year: 2023,
            month: 10,
            day: 15,
            hour: 14,
            minute: 51,
            second: 5
        )
        
        XCTAssertEqual(
            recentTracks.items[1].date,
            Calendar.current.date(from: dateComponents)
        )
        
        XCTAssertEqual(recentTracks.items[2].artist.mbid, "fbbad867-cff9-4974-9702-18bd252b04e7")
        XCTAssertEqual(recentTracks.items[2].artist.name, "Damone")
        XCTAssertEqual(recentTracks.items[2].streamable, false)
        
        XCTAssertEqual(
            recentTracks.items[2].image.small?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/34s/a33900373fa946a0bbb48f8dcdda5904.png"
        )
        
        XCTAssertEqual(
            recentTracks.items[2].image.medium?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/64s/a33900373fa946a0bbb48f8dcdda5904.png"
        )
        
        XCTAssertEqual(
            recentTracks.items[2].image.large?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/174s/a33900373fa946a0bbb48f8dcdda5904.png"
        )
        
        XCTAssertEqual(
            recentTracks.items[2].image.extraLarge?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/300x300/a33900373fa946a0bbb48f8dcdda5904.png"
        )
        
        XCTAssertNil(recentTracks.items[2].image.mega)
        XCTAssertEqual(recentTracks.items[2].mbid, "4f6cb9fe-e59a-3d5f-bb14-cb4431eb3418")
        XCTAssertEqual(recentTracks.items[2].album.mbid, "96130b06-fa9c-453d-b4e0-604685a6cc02")
        XCTAssertEqual(recentTracks.items[2].album.name, "Out Here All Night")
        XCTAssertEqual(recentTracks.items[2].name, "What We Came Here For")
        XCTAssertEqual(recentTracks.items[2].url.absoluteString, "https://www.last.fm/music/Damone/_/What+We+Came+Here+For")
        XCTAssertEqual(recentTracks.items[2].nowPlaying, false)
        XCTAssertEqual(recentTracks.items[2].date, Date(timeIntervalSince1970: 1697381235))
    }
    
    func test_getRecentTracks_success() async throws {
        let jsonURL = Bundle.module.url(
            forResource: "Resources/user.getRecentTracks",
            withExtension: "json"
        )!

        let fakeData = try Data(contentsOf: jsonURL)
        let params = RecentTracksParams(user: "someUser", limit: 2, page: 1)

        apiClientMock.data = fakeData
        apiClientMock.response = Constants.RESPONSE_200_OK
        
        let recentTracks = try await instance.getRecentTracks(params: params)

        validateUserRecentTracksSuccessResponse(recentTracks)
        
        XCTAssertEqual(apiClientMock.asyncGetCalls.count, 1)
        XCTAssertEqual(apiClientMock.asyncGetCalls[0].headers, nil)

        XCTAssertTrue(
            Util.areSameURL(
                apiClientMock.asyncGetCalls[0].url.absoluteString,
                "https://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=\(params.user)&extended=0&limit=\(params.limit)&api_key=\(Constants.API_KEY)&format=json&page=\(params.page)"
            )
        )
    }
    
    func test_getRecentTracks_success() throws {
        let jsonURL = Bundle.module.url(
            forResource: "Resources/user.getRecentTracks",
            withExtension: "json"
        )!

        let fakeData = try Data(contentsOf: jsonURL)
        let expectation = expectation(description: "waiting for getRecentTracks")
        let params = RecentTracksParams(user: "someUser", limit: 2, page: 1)

        apiClientMock.data = fakeData
        apiClientMock.response = Constants.RESPONSE_200_OK

        instance.getRecentTracks(params: params) { result in
            switch(result) {
            case .success(let recentTracks):
                self.validateUserRecentTracksSuccessResponse(recentTracks)
            case .failure(_):
                XCTFail("Expected to succeed but it failed")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 3)
        XCTAssertEqual(apiClientMock.getCalls.count, 1)
        XCTAssertEqual(apiClientMock.getCalls[0].headers, nil)

        XCTAssertTrue(
            Util.areSameURL(
                apiClientMock.getCalls[0].url.absoluteString,
                "https://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=\(params.user)&extended=0&limit=\(params.limit)&api_key=\(Constants.API_KEY)&format=json&page=\(params.page)"
            )
        )
    }
    
    func test_getRecentTracks_failure() async throws {
        let params = RecentTracksParams(user: "pepito")

        apiClientMock.error = RuntimeError("fake error")
        
        do {
            let _ = try await instance.getRecentTracks(params: params)
            XCTFail("It was expected to fail, but it succeeded")
        } catch {
            XCTAssertTrue(true)
        }
    }

    func test_getRecentTracks_failure() throws {
        let params = RecentTracksParams(user: "pepito")
        let expectation = expectation(description: "waiting for getRecentTracks")

        apiClientMock.error = RuntimeError("fake error")

        instance.getRecentTracks(params: params) { result in
            switch(result) {
            case .success(_):
                XCTFail("It was expected to fail, but it succeeded")
            case .failure(_):
                XCTAssertTrue(true)
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 3)
    }

    // getExtendedRecentTracks

    fileprivate func validateUserExtendedRecentTracksSuccessResponse(_ recentTracks: (CollectionPage<ExtendedRecentTrack>)) {
        XCTAssertEqual(recentTracks.items[0].artist.url.absoluteString, "https://www.last.fm/music/Mew")
        XCTAssertEqual(recentTracks.items[0].artist.name, "Mew")
        
        XCTAssertEqual(
            recentTracks.items[0].artist.image.small?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/34s/2a96cbd8b46e442fc41c2b86b821562f.png"
        )
        
        XCTAssertEqual(
            recentTracks.items[0].artist.image.medium?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/64s/2a96cbd8b46e442fc41c2b86b821562f.png"
        )
        
        XCTAssertEqual(
            recentTracks.items[0].artist.image.large?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/174s/2a96cbd8b46e442fc41c2b86b821562f.png"
        )
        
        XCTAssertEqual(
            recentTracks.items[0].artist.image.extraLarge?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/300x300/2a96cbd8b46e442fc41c2b86b821562f.png"
        )
        
        XCTAssertEqual(recentTracks.items[0].mbid, "1e8cf157-9f5f-3e7c-ac82-c59259970a92")
        XCTAssertEqual(recentTracks.items[0].name, "Symmetry")
        
        XCTAssertEqual(
            recentTracks.items[0].image.small?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/34s/87480021191328af5dc130dd879d8bd2.png"
        )
        
        XCTAssertEqual(
            recentTracks.items[0].image.medium?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/64s/87480021191328af5dc130dd879d8bd2.png"
        )
        
        XCTAssertEqual(
            recentTracks.items[0].image.large?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/174s/87480021191328af5dc130dd879d8bd2.png"
        )
        
        XCTAssertEqual(
            recentTracks.items[0].image.extraLarge?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/300x300/87480021191328af5dc130dd879d8bd2.png"
        )
        
        XCTAssertEqual(recentTracks.items[0].streamable, false)
        XCTAssertEqual(recentTracks.items[0].album.mbid, "17486085-c26f-3e0e-a8af-e5d91dece258")
        XCTAssertEqual(recentTracks.items[0].album.name, "Half the World Is Watching Me")
        
        XCTAssertEqual(
            recentTracks.items[0].url.absoluteString,
            "https://www.last.fm/music/Mew/_/Symmetry"
        )
        
        XCTAssertEqual(recentTracks.items[0].nowPlaying, true)
        XCTAssertEqual(recentTracks.items[0].loved, true)
        
        XCTAssertEqual(recentTracks.items[1].artist.url.absoluteString, "https://www.last.fm/music/Nine+Inch+Nails")
        XCTAssertEqual(recentTracks.items[1].artist.name, "Nine Inch Nails")
        
        XCTAssertEqual(
            recentTracks.items[1].artist.image.small?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/34s/2a96cbd8b46e442fc41c2b86b821562f.png"
        )
        
        XCTAssertEqual(
            recentTracks.items[1].artist.image.medium?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/64s/2a96cbd8b46e442fc41c2b86b821562f.png"
        )
        
        XCTAssertEqual(
            recentTracks.items[1].artist.image.large?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/174s/2a96cbd8b46e442fc41c2b86b821562f.png"
        )
        
        XCTAssertEqual(
            recentTracks.items[1].artist.image.extraLarge?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/300x300/2a96cbd8b46e442fc41c2b86b821562f.png"
        )
        
        let dateComponents = DateComponents(
            calendar: Calendar.current,
            timeZone: TimeZone(secondsFromGMT: 0),
            year: 2023,
            month: 10,
            day: 15,
            hour: 15,
            minute: 15,
            second: 18
        )
        
        XCTAssertEqual(
            recentTracks.items[1].date,
            Calendar.current.date(from: dateComponents)
        )
        
        XCTAssertEqual(recentTracks.items[1].mbid, "3a1b35a6-5291-393b-a6ba-7afdfabf22b1")
        XCTAssertEqual(recentTracks.items[1].name, "Echoplex")
        
        XCTAssertEqual(
            recentTracks.items[1].image.small?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/34s/86bf0aab05704d2e880dc37384485c32.png"
        )
        
        XCTAssertEqual(
            recentTracks.items[1].image.medium?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/64s/86bf0aab05704d2e880dc37384485c32.png"
        )
        
        XCTAssertEqual(
            recentTracks.items[1].image.large?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/174s/86bf0aab05704d2e880dc37384485c32.png"
        )
        
        XCTAssertEqual(
            recentTracks.items[1].image.extraLarge?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/300x300/86bf0aab05704d2e880dc37384485c32.png"
        )
        
        XCTAssertEqual(recentTracks.items[1].streamable, false)
        XCTAssertEqual(recentTracks.items[1].album.mbid, "12b57d46-a192-499e-a91f-7da66790a1c1")
        XCTAssertEqual(recentTracks.items[1].album.name, "The Slip")
        
        XCTAssertEqual(
            recentTracks.items[1].url.absoluteString,
            "https://www.last.fm/music/Nine+Inch+Nails/_/Echoplex"
        )
        
        XCTAssertEqual(recentTracks.items[1].nowPlaying, false)
        XCTAssertEqual(recentTracks.items[1].loved, true)
        
        XCTAssertEqual(recentTracks.items[2].artist.url.absoluteString, "https://www.last.fm/music/Tripping+Daisy")
        XCTAssertEqual(recentTracks.items[2].artist.name, "Tripping Daisy")
        
        XCTAssertEqual(
            recentTracks.items[2].artist.image.small?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/34s/2a96cbd8b46e442fc41c2b86b821562f.png"
        )
        
        XCTAssertEqual(
            recentTracks.items[2].artist.image.medium?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/64s/2a96cbd8b46e442fc41c2b86b821562f.png"
        )
        
        XCTAssertEqual(
            recentTracks.items[2].artist.image.large?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/174s/2a96cbd8b46e442fc41c2b86b821562f.png"
        )
        
        XCTAssertEqual(
            recentTracks.items[2].artist.image.extraLarge?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/300x300/2a96cbd8b46e442fc41c2b86b821562f.png"
        )
        
        XCTAssertEqual(recentTracks.items[2].date, Date(timeIntervalSince1970: 1697382463))
        XCTAssertEqual(recentTracks.items[2].mbid, "13b0034d-b4fe-4bb2-aca3-bd2498d222d4")
        XCTAssertEqual(recentTracks.items[2].name, "Raindrop")
        
        XCTAssertEqual(
            recentTracks.items[2].image.small?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/34s/cf8db55462804578b1e6d0c5c99b6409.jpg"
        )
        
        XCTAssertEqual(
            recentTracks.items[2].image.medium?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/64s/cf8db55462804578b1e6d0c5c99b6409.jpg"
        )
        
        XCTAssertEqual(
            recentTracks.items[2].image.large?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/174s/cf8db55462804578b1e6d0c5c99b6409.jpg"
        )
        
        XCTAssertEqual(
            recentTracks.items[2].image.extraLarge?.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/300x300/cf8db55462804578b1e6d0c5c99b6409.jpg"
        )
        
        XCTAssertEqual(recentTracks.items[2].streamable, false)
        XCTAssertEqual(recentTracks.items[2].album.mbid, "6233a746-932e-38d0-9dea-073be3ce1606")
        XCTAssertEqual(recentTracks.items[2].album.name, "I Am An Elastic Firecracker")
        
        XCTAssertEqual(
            recentTracks.items[2].url.absoluteString,
            "https://www.last.fm/music/Tripping+Daisy/_/Raindrop"
        )
        
        XCTAssertEqual(recentTracks.items[2].nowPlaying, false)
        XCTAssertEqual(recentTracks.items[2].loved, false)
    }
    
    func test_getExtendedRecentTracks_success() async throws {
        let jsonURL = Bundle.module.url(
            forResource: "Resources/user.getExtendedRecentTracks",
            withExtension: "json"
        )!

        let fakeData = try Data(contentsOf: jsonURL)

        let params = RecentTracksParams(
            user: "Pepito",
            limit: 5,
            page: 1,
            from: 23454646,
            to: 345646343
        )

        apiClientMock.data = fakeData
        apiClientMock.response = Constants.RESPONSE_200_OK
        
        let recentTracks = try await instance.getExtendedRecentTracks(params: params)

        validateUserExtendedRecentTracksSuccessResponse(recentTracks)
        
        XCTAssertEqual(apiClientMock.asyncGetCalls.count, 1)
        XCTAssertEqual(apiClientMock.asyncGetCalls[0].headers, nil)

        XCTAssertTrue(
            Util.areSameURL(
                apiClientMock.asyncGetCalls[0].url.absoluteString,
                "https://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=\(params.user)&extended=1&limit=\(params.limit)&api_key=\(Constants.API_KEY)&format=json&page=\(params.page)&from=\(params.from!)&to=\(params.to!)"
            )
        )
    }
    
    func test_getExtendedRecentTracks_success() throws {
        let jsonURL = Bundle.module.url(
            forResource: "Resources/user.getExtendedRecentTracks",
            withExtension: "json"
        )!

        let fakeData = try Data(contentsOf: jsonURL)
        let expectation = expectation(description: "waiting for getExtendedRecentTracks")

        let params = RecentTracksParams(
            user: "Pepito",
            limit: 5,
            page: 1,
            from: 23454646,
            to: 345646343
        )

        apiClientMock.data = fakeData
        apiClientMock.response = Constants.RESPONSE_200_OK

        instance.getExtendedRecentTracks(params: params) { result in
            switch(result) {
            case .success(let recentTracks):
                self.validateUserExtendedRecentTracksSuccessResponse(recentTracks)
            case .failure(_):
                XCTFail("It was expected to fail, but it succeeded instead")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 3)
        XCTAssertEqual(apiClientMock.getCalls.count, 1)
        XCTAssertEqual(apiClientMock.getCalls[0].headers, nil)

        XCTAssertTrue(
            Util.areSameURL(
                apiClientMock.getCalls[0].url.absoluteString,
                "https://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=\(params.user)&extended=1&limit=\(params.limit)&api_key=\(Constants.API_KEY)&format=json&page=\(params.page)&from=\(params.from!)&to=\(params.to!)"
            )
        )
    }
    
    func test_getExtendedRecentTracks_failure() async throws {
        let params = RecentTracksParams(user: "trent")

        apiClientMock.error = RuntimeError("Beautiful error")
        
        do {
            let _ = try await instance.getExtendedRecentTracks(params: params)
            XCTFail("It was expected to fail, but it succeeded instead")
        } catch {
            XCTAssertTrue(true)
        }
    }

    func test_getExtendedRecentTracks_failure() throws {
        let expectation = expectation(description: "waiting for getExtendedRecentTracks")
        let params = RecentTracksParams(user: "trent")

        apiClientMock.error = RuntimeError("Beautiful error")

        instance.getExtendedRecentTracks(params: params) { result in
            switch(result) {
            case .success(_):
                XCTFail("It was expected to fail, but it succeeded instead")
            case .failure(_):
                XCTAssertTrue(true)
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 3)
    }

    // getTopTracks

    fileprivate func validateUserTopTracksSuccessResponse(_ topTracks: (CollectionPage<UserTopTrack>)) {
        XCTAssertEqual(topTracks.items.count, 2)
        XCTAssertEqual(topTracks.pagination.total, 48)
        XCTAssertEqual(topTracks.pagination.totalPages, 24)
        XCTAssertEqual(topTracks.pagination.perPage, 2)
        XCTAssertEqual(topTracks.pagination.page, 1)
        
        XCTAssertEqual(topTracks.items[0].streamable, .noStreamable)
        XCTAssertEqual(topTracks.items[0].mbid, "track-0-mbid")
        XCTAssertEqual(topTracks.items[0].name, "Track 0")
        XCTAssertEqual(topTracks.items[0].image.small?.absoluteString, "https://images.com/artist-0-s.png")
        XCTAssertEqual(topTracks.items[0].image.medium?.absoluteString, "https://images.com/artist-0-m.png")
        XCTAssertEqual(topTracks.items[0].image.large?.absoluteString, "https://images.com/artist-0-l.png")
        XCTAssertEqual(topTracks.items[0].image.extraLarge?.absoluteString, "https://images.com/artist-0-xl.png")
        XCTAssertEqual(topTracks.items[0].artist.url.absoluteString, "https://artists.com/artist-0")
        XCTAssertEqual(topTracks.items[0].artist.name, "Artist 0")
        XCTAssertEqual(topTracks.items[0].artist.mbid, "artist-0-mbid")
        XCTAssertEqual(topTracks.items[0].url.absoluteString, "https://tracks.com/track-0")
        XCTAssertEqual(topTracks.items[0].duration, 600)
        XCTAssertEqual(topTracks.items[0].rank, 1)
        
        XCTAssertEqual(topTracks.items[0].playcount, 20)
        XCTAssertEqual(topTracks.items[1].streamable, .noStreamable)
        XCTAssertEqual(topTracks.items[1].mbid, "track-1-mbid")
        XCTAssertEqual(topTracks.items[1].name, "Track 1")
        XCTAssertEqual(topTracks.items[1].image.small?.absoluteString, "https://images.com/artist-1-s.png")
        XCTAssertEqual(topTracks.items[1].image.medium?.absoluteString, "https://images.com/artist-1-m.png")
        XCTAssertEqual(topTracks.items[1].image.large?.absoluteString, "https://images.com/artist-1-l.png")
        XCTAssertEqual(topTracks.items[1].image.extraLarge?.absoluteString, "https://images.com/artist-1-xl.png")
        XCTAssertEqual(topTracks.items[1].artist.url.absoluteString, "https://artists.com/artist-1")
        XCTAssertEqual(topTracks.items[1].artist.name, "Artist 1")
        XCTAssertEqual(topTracks.items[1].artist.mbid, "artist-1-mbid")
        XCTAssertEqual(topTracks.items[1].url.absoluteString, "https://tracks.com/track-1")
        XCTAssertEqual(topTracks.items[1].duration, 610)
        XCTAssertEqual(topTracks.items[1].rank, 2)
        XCTAssertEqual(topTracks.items[1].playcount, 21)
    }
    
    func test_getTopTracks_success() async throws {
        let jsonURL = Bundle.module.url(
            forResource: "Resources/user.getTopTracks",
            withExtension: "json"
        )!

        let fakeData = try Data(contentsOf: jsonURL)

        let params = UserTopItemsParams(
            user: "pepito",
            period: .last180days,
            limit: 34,
            page: 234
        )

        apiClientMock.data = fakeData
        apiClientMock.response = Constants.RESPONSE_200_OK

        let topTracks = try await instance.getTopTracks(params: params)

        validateUserTopTracksSuccessResponse(topTracks)
        
        XCTAssertEqual(apiClientMock.asyncPostCalls.count, 0)
        XCTAssertEqual(apiClientMock.asyncGetCalls.count, 1)
        XCTAssertNil(apiClientMock.asyncGetCalls[0].headers)

        XCTAssertTrue(
            Util.areSameURL(
                apiClientMock.asyncGetCalls[0].url.absoluteString,
                "https://ws.audioscrobbler.com/2.0?method=user.gettoptracks&user=\(params.user)&limit=\(params.limit)&page=\(params.page)&period=\(params.period.rawValue)&api_key=\(Constants.API_KEY)&format=json"
            )
        )
    }
    
    func test_getTopTracks_success() throws {
        let jsonURL = Bundle.module.url(
            forResource: "Resources/user.getTopTracks",
            withExtension: "json"
        )!

        let fakeData = try Data(contentsOf: jsonURL)

        let params = UserTopItemsParams(
            user: "pepito",
            period: .last180days,
            limit: 34,
            page: 234
        )

        apiClientMock.data = fakeData
        apiClientMock.response = Constants.RESPONSE_200_OK

        let expectation = expectation(description: "waiting for succesful getTopTracks")

        instance.getTopTracks(params: params) { result in
            switch (result) {
            case .success(let topTracks):
                self.validateUserTopTracksSuccessResponse(topTracks)
            case .failure(let error):
                XCTFail("Expected to be a success but got a failure with \(error)")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 3)
        XCTAssertEqual(apiClientMock.postCalls.count, 0)
        XCTAssertEqual(apiClientMock.getCalls.count, 1)
        XCTAssertNil(apiClientMock.getCalls[0].headers)

        XCTAssertTrue(
            Util.areSameURL(
                apiClientMock.getCalls[0].url.absoluteString,
                "https://ws.audioscrobbler.com/2.0?method=user.gettoptracks&user=\(params.user)&limit=\(params.limit)&page=\(params.page)&period=\(params.period.rawValue)&api_key=\(Constants.API_KEY)&format=json"
            )
        )
    }
    
    func test_getTopTracks_failure() async throws {
        let params = UserTopItemsParams(
            user: "user",
            period: .last180days,
            limit: 10,
            page: 2
        )

        let error = RuntimeError("Fake error")
        apiClientMock.error = error
        
        do {
            let _ = try await instance.getTopTracks(params: params)
            XCTFail("Expected to fail, but it succeeded")
        } catch let error where error is RuntimeError {
            XCTAssertEqual(error.localizedDescription, "Fake error")
        } catch {
            XCTFail("Expected to be a Runtime \"Fake error\" error")
        }
    }

    func test_getTopTracks_failure() throws {
        let params = UserTopItemsParams(
            user: "user",
            period: .last180days,
            limit: 10,
            page: 2
        )

        let error = RuntimeError("Fake error")
        apiClientMock.error = error

        let expectation = expectation(description: "waiting for failure getTopTracks")

        instance.getTopTracks(params: params) { result in
            switch (result) {
            case .success( _):
                XCTFail("Expected to fail, but it succeeded")
            case .failure(LastFMError.OtherError(let error)):
                XCTAssert(error is RuntimeError)
                XCTAssertEqual(error.localizedDescription, "Fake error")
            default:
                XCTFail("Expected to be a Runtime \"Fake error\" error")
                break
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 3)
    }

    // getWeeklyTrackChart

    fileprivate func validateUserWeeklyTrackChartSuccessResponse(_ tracks: (CollectionList<UserWeeklyTrackChart>)) {
        XCTAssertEqual(tracks.items.count, 2)
        
        XCTAssertEqual(tracks.items[0].artist.mbid, "artist-0-mbid")
        XCTAssertEqual(tracks.items[0].artist.name, "Artist 0")
        XCTAssertEqual(tracks.items[0].image.small?.absoluteString, "https://images.com/track-0-s.png")
        XCTAssertEqual(tracks.items[0].image.medium?.absoluteString, "https://images.com/track-0-m.png")
        XCTAssertEqual(tracks.items[0].image.large?.absoluteString, "https://images.com/track-0-l.png")
        XCTAssertEqual(tracks.items[0].mbid, "track-0-mbid")
        XCTAssertEqual(tracks.items[0].url.absoluteString, "https://tracks.com/track-0")
        XCTAssertEqual(tracks.items[0].name, "Track 0")
        XCTAssertEqual(tracks.items[0].rank, 1)
        XCTAssertEqual(tracks.items[0].playcount, 4500)
        
        XCTAssertEqual(tracks.items[1].artist.mbid, "artist-1-mbid")
        XCTAssertEqual(tracks.items[1].artist.name, "Artist 1")
        XCTAssertEqual(tracks.items[1].image.small?.absoluteString, "https://images.com/track-1-s.png")
        XCTAssertEqual(tracks.items[1].image.medium?.absoluteString, "https://images.com/track-1-m.png")
        XCTAssertEqual(tracks.items[1].image.large?.absoluteString, "https://images.com/track-1-l.png")
        XCTAssertEqual(tracks.items[1].mbid, "track-1-mbid")
        XCTAssertEqual(tracks.items[1].url.absoluteString, "https://tracks.com/track-1")
        XCTAssertEqual(tracks.items[1].name, "Track 1")
        XCTAssertEqual(tracks.items[1].rank, 2)
        XCTAssertEqual(tracks.items[1].playcount, 4510)
    }
    
    func test_getWeeklyTrackChart_success() async throws {
        let jsonURL = Bundle.module.url(
            forResource: "Resources/user.getWeeklyTrackChart",
            withExtension: "json"
        )!

        let fakeData = try Data(contentsOf: jsonURL)
        let params = UserWeeklyChartParams(user: "user", from: 123412, to: 53452)

        apiClientMock.data = fakeData
        apiClientMock.response = Constants.RESPONSE_200_OK
        
        let tracks = try await instance.getWeeklyTrackChart(params: params)

        validateUserWeeklyTrackChartSuccessResponse(tracks)

        XCTAssertEqual(apiClientMock.asyncPostCalls.count, 0)
        XCTAssertEqual(apiClientMock.asyncGetCalls.count, 1)
        XCTAssertEqual(apiClientMock.asyncGetCalls[0].headers, nil)

        XCTAssertTrue(
            Util.areSameURL(
                apiClientMock.asyncGetCalls[0].url.absoluteString,
                "https://ws.audioscrobbler.com/2.0?method=user.getweeklytrackchart&user=\(params.user)&from=\(params.from)&to=\(params.to)&api_key=\(Constants.API_KEY)&format=json"
            )
        )
    }
    
    func test_getWeeklyTrackChart_success() throws {
        let jsonURL = Bundle.module.url(
            forResource: "Resources/user.getWeeklyTrackChart",
            withExtension: "json"
        )!

        let fakeData = try Data(contentsOf: jsonURL)
        let params = UserWeeklyChartParams(user: "user", from: 123412, to: 53452)

        apiClientMock.data = fakeData
        apiClientMock.response = Constants.RESPONSE_200_OK

        let expectation = expectation(description: "Waiting for getWeeklyTrackChart")

        instance.getWeeklyTrackChart(params: params) { result in
            switch (result) {
            case .success(let tracks):
                self.validateUserWeeklyTrackChartSuccessResponse(tracks)
            case .failure(let error):
                XCTFail("Expected to be a success but got a failure with \(error)")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 3)

        XCTAssertEqual(apiClientMock.postCalls.count, 0)
        XCTAssertEqual(apiClientMock.getCalls.count, 1)
        XCTAssertEqual(apiClientMock.getCalls[0].headers, nil)

        XCTAssertTrue(
            Util.areSameURL(
                apiClientMock.getCalls[0].url.absoluteString,
                "https://ws.audioscrobbler.com/2.0?method=user.getweeklytrackchart&user=\(params.user)&from=\(params.from)&to=\(params.to)&api_key=\(Constants.API_KEY)&format=json"
            )
        )
    }
    
    func test_getWeeklyTrackChart_failure() async throws {
        let params = UserWeeklyChartParams(user: "asdf", from: 3452, to: 56433)

        apiClientMock.error = RuntimeError("Fake error")
        
        do {
            let _ = try await instance.getWeeklyTrackChart(params: params)
            XCTFail("Expected to fail, but it succeeded")
        } catch let error where error is RuntimeError {
            XCTAssertEqual(error.localizedDescription, "Fake error")
        } catch {
            XCTFail("Expected to be a Runtime \"Fake error\" error")
        }
    }

    func test_getWeeklyTrackChart_failure() throws {
        let params = UserWeeklyChartParams(user: "asdf", from: 3452, to: 56433)
        let expectation = expectation(description: "Waiting for getWeeklyTrackChart")
        apiClientMock.error = RuntimeError("Fake error")

        instance.getWeeklyTrackChart(params: params) { result in
            switch (result) {
            case .success( _):
                XCTFail("Expected to fail, but it succeeded")
            case .failure(LastFMError.OtherError(let error)):
                XCTAssert(error is RuntimeError)
                XCTAssertEqual(error.localizedDescription, "Fake error")
            default:
                XCTFail("Expected to be a Runtime \"Fake error\" error")
                break
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 3)
    }

    // getLovedTracks

    fileprivate func validateUserLovedTracksSuccessResponse(_ lovedTracks: (CollectionPage<LovedTrack>)) {
        XCTAssertEqual(lovedTracks.items[0].artist.url.absoluteString, "https://artists.com/artist-0")
        XCTAssertEqual(lovedTracks.items[0].artist.name, "Artist 0")
        XCTAssertEqual(lovedTracks.items[0].artist.mbid, "")
        
        let dateComponents = DateComponents(
            calendar: Calendar.current,
            timeZone: TimeZone(secondsFromGMT: 0),
            year: 2023,
            month: 9,
            day: 20,
            hour: 1,
            minute: 26,
            second: 20
        )
        
        XCTAssertEqual(lovedTracks.items[0].date, Calendar.current.date(from: dateComponents))
        XCTAssertEqual(lovedTracks.items[0].mbid, "artist-0-mbid")
        XCTAssertEqual(lovedTracks.items[0].url.absoluteString, "https://tracks.com/track-0")
        XCTAssertEqual(lovedTracks.items[0].name, "Track 0")
        XCTAssertEqual(lovedTracks.items[0].image.small?.absoluteString, "https://images.com/artist-0-s.png")
        XCTAssertEqual(lovedTracks.items[0].image.medium?.absoluteString, "https://images.com/artist-0-m.png")
        XCTAssertEqual(lovedTracks.items[0].image.large?.absoluteString, "https://images.com/artist-0-l.png")
        XCTAssertEqual(lovedTracks.items[0].image.extraLarge?.absoluteString, "https://images.com/artist-0-xl.png")
        XCTAssertNil(lovedTracks.items[0].image.mega)
        XCTAssertEqual(lovedTracks.items[1].artist.url.absoluteString, "https://artists.com/artist-1")
        XCTAssertEqual(lovedTracks.items[1].artist.name, "Artist 1")
        XCTAssertEqual(lovedTracks.items[1].artist.mbid, "")
        
        let dateComponents2 = DateComponents(
            calendar: Calendar.current,
            timeZone: TimeZone(secondsFromGMT: 0),
            year: 2023,
            month: 10,
            day: 13,
            hour: 23,
            minute: 12,
            second: 42
        )
        
        XCTAssertEqual(lovedTracks.items[1].date, Calendar.current.date(from: dateComponents2))
        XCTAssertEqual(lovedTracks.items[1].mbid, "artist-1-mbid")
        XCTAssertEqual(lovedTracks.items[1].url.absoluteString, "https://tracks.com/track-1")
        XCTAssertEqual(lovedTracks.items[1].name, "Track 1")
        XCTAssertEqual(lovedTracks.items[1].image.small?.absoluteString, "https://images.com/artist-1-s.png")
        XCTAssertEqual(lovedTracks.items[1].image.medium?.absoluteString, "https://images.com/artist-1-m.png")
        XCTAssertEqual(lovedTracks.items[1].image.large?.absoluteString, "https://images.com/artist-1-l.png")
        XCTAssertEqual(lovedTracks.items[1].image.extraLarge?.absoluteString, "https://images.com/artist-1-xl.png")
        XCTAssertNil(lovedTracks.items[1].image.mega)
    }
    
    func test_getLovedTracks_success() async throws {
        let fakeDataURL = Bundle.module.url(forResource: "Resources/user.getLovedTracks", withExtension: "json")!
        let fakeData = try Data(contentsOf: fakeDataURL)
        let params = SearchParams(term: "someUser", limit: 5, page: 12)

        apiClientMock.data = fakeData
        apiClientMock.response = Constants.RESPONSE_200_OK
        
        let lovedTracks = try await instance.getLovedTracks(params: params)

        validateUserLovedTracksSuccessResponse(lovedTracks)
        
        XCTAssertEqual(apiClientMock.asyncGetCalls.count, 1)
        XCTAssertEqual(apiClientMock.asyncGetCalls[0].headers, nil)

        XCTAssertTrue(
            Util.areSameURL(
                apiClientMock.asyncGetCalls[0].url.absoluteString,
                "https://ws.audioscrobbler.com/2.0?method=user.getlovedtracks&user=someUser&limit=5&page=12&api_key=\(Constants.API_KEY)&format=json"
            )
        )
    }
    
    func test_getLovedTracks_success() throws {
        let fakeDataURL = Bundle.module.url(forResource: "Resources/user.getLovedTracks", withExtension: "json")!
        let fakeData = try Data(contentsOf: fakeDataURL)
        let params = SearchParams(term: "someUser", limit: 5, page: 12)
        let expectation = expectation(description: "waiting for getLovedTracks")

        apiClientMock.data = fakeData
        apiClientMock.response = Constants.RESPONSE_200_OK

        instance.getLovedTracks(params: params) { result in
            switch(result) {
            case .success(let lovedTracks):
                self.validateUserLovedTracksSuccessResponse(lovedTracks)
            case .failure(let error):
                XCTFail("Expected to succeed, but it fail with error: \(error.localizedDescription)")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 3)
        XCTAssertEqual(apiClientMock.getCalls.count, 1)
        XCTAssertEqual(apiClientMock.getCalls[0].headers, nil)

        XCTAssertTrue(
            Util.areSameURL(
                apiClientMock.getCalls[0].url.absoluteString,
                "https://ws.audioscrobbler.com/2.0?method=user.getlovedtracks&user=someUser&limit=5&page=12&api_key=\(Constants.API_KEY)&format=json"
            )
        )
    }
    
    func test_getLovedTracks_failure() async throws {
        let params = SearchParams(term: "Copo", limit: 345, page: 345)

        apiClientMock.error = RuntimeError("Any error")
        
        do {
            let _ = try await instance.getLovedTracks(params: params)
            XCTFail("Expected to fail, but it succeed.")
        } catch {
            XCTAssert(true)
        }
    }

    func test_getLovedTracks_failure() throws {
        let params = SearchParams(term: "Copo", limit: 345, page: 345)
        let expectation = expectation(description: "waiting for getLovedTracks")

        apiClientMock.error = RuntimeError("Any error")

        instance.getLovedTracks(params: params) { result in
            switch(result) {
            case .success(_):
                XCTFail("Expected to fail, but it succeed.")
            case .failure(_):
                XCTAssert(true)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 3)
    }

    // getTopArtists

    fileprivate func validateUserTopArtistsSuccessResponse(_ artists: (CollectionPage<UserTopArtist>)) {
        XCTAssertEqual(artists.items.count, 2)
        XCTAssertEqual(artists.pagination.totalPages, 10)
        XCTAssertEqual(artists.pagination.page, 1)
        XCTAssertEqual(artists.pagination.total, 20)
        XCTAssertEqual(artists.pagination.perPage, 2)
        
        XCTAssertEqual(artists.items[0].streamable, false)
        XCTAssertEqual(artists.items[0].image.small?.absoluteString, "https://images.com/image-0-s.png")
        XCTAssertEqual(artists.items[0].image.medium?.absoluteString, "https://images.com/image-0-m.png")
        XCTAssertEqual(artists.items[0].image.large?.absoluteString, "https://images.com/image-0-l.png")
        XCTAssertEqual(artists.items[0].image.extraLarge?.absoluteString, "https://images.com/image-0-xl.png")
        XCTAssertEqual(artists.items[0].image.mega?.absoluteString, "https://images.com/image-0-mg.png")
        XCTAssertEqual(artists.items[0].mbid, "artist-0-mbid")
        XCTAssertEqual(artists.items[0].url.absoluteString, "https://artists.com/artist-0")
        XCTAssertEqual(artists.items[0].playcount, 3400)
        XCTAssertEqual(artists.items[0].rank, 1)
        XCTAssertEqual(artists.items[0].name, "Artist 0")
        
        XCTAssertEqual(artists.items[1].streamable, false)
        XCTAssertEqual(artists.items[1].image.small?.absoluteString, "https://images.com/image-1-s.png")
        XCTAssertEqual(artists.items[1].image.medium?.absoluteString, "https://images.com/image-1-m.png")
        XCTAssertEqual(artists.items[1].image.large?.absoluteString, "https://images.com/image-1-l.png")
        XCTAssertEqual(artists.items[1].image.extraLarge?.absoluteString, "https://images.com/image-1-xl.png")
        XCTAssertEqual(artists.items[1].image.mega?.absoluteString, "https://images.com/image-1-mg.png")
        XCTAssertEqual(artists.items[1].mbid, "artist-1-mbid")
        XCTAssertEqual(artists.items[1].url.absoluteString, "https://artists.com/artist-1")
        XCTAssertEqual(artists.items[1].playcount, 3410)
        XCTAssertEqual(artists.items[1].rank, 2)
        XCTAssertEqual(artists.items[1].name, "Artist 1")
    }
    
    func test_getTopArtists_success() async throws {
        let fakeDataURL = Bundle.module.url(forResource: "Resources/user.getTopArtists", withExtension: "json")!
        let fakeData = try Data(contentsOf: fakeDataURL)
        let params = UserTopItemsParams(user: "someUser", limit: 5, page: 12)

        apiClientMock.data = fakeData
        apiClientMock.response = Constants.RESPONSE_200_OK
        
        let artists = try await instance.getTopArtists(params: params)

        validateUserTopArtistsSuccessResponse(artists)
        
        XCTAssertEqual(apiClientMock.asyncGetCalls.count, 1)
        XCTAssertEqual(apiClientMock.asyncGetCalls[0].headers, nil)

        XCTAssertTrue(
            Util.areSameURL(
                apiClientMock.asyncGetCalls[0].url.absoluteString,
                "https://ws.audioscrobbler.com/2.0?method=user.gettopartists&user=\(params.user)&period=\(params.period)&limit=\(params.limit)&page=\(params.page)&api_key=\(Constants.API_KEY)&format=json"
            )
        )
    }
    
    func test_getTopArtists_success() throws {
        let fakeDataURL = Bundle.module.url(forResource: "Resources/user.getTopArtists", withExtension: "json")!
        let fakeData = try Data(contentsOf: fakeDataURL)
        let params = UserTopItemsParams(user: "someUser", limit: 5, page: 12)
        let expectation = expectation(description: "waiting for getTopArtists")

        apiClientMock.data = fakeData
        apiClientMock.response = Constants.RESPONSE_200_OK

        instance.getTopArtists(params: params) { result in
            switch(result) {
            case .success(let artists):
                self.validateUserTopArtistsSuccessResponse(artists)
            case .failure(let error):
                XCTFail("Expected to succeed, but it fail with error: \(error.localizedDescription)")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 3)
        XCTAssertEqual(apiClientMock.getCalls.count, 1)
        XCTAssertEqual(apiClientMock.getCalls[0].headers, nil)

        XCTAssertTrue(
            Util.areSameURL(
                apiClientMock.getCalls[0].url.absoluteString,
                "https://ws.audioscrobbler.com/2.0?method=user.gettopartists&user=\(params.user)&period=\(params.period)&limit=\(params.limit)&page=\(params.page)&api_key=\(Constants.API_KEY)&format=json"
            )
        )
    }
    
    func test_getTopArtists_failure() async throws {
        let params = UserTopItemsParams(user: "Copo", limit: 345, page: 345)

        apiClientMock.error = RuntimeError("Any error")
        
        do {
            let _ = try await instance.getTopArtists(params: params)
            XCTFail("Expected to fail, but it succeed.")
        } catch {
            XCTAssert(true)
        }
    }

    func test_getTopArtists_failure() throws {
        let params = UserTopItemsParams(user: "Copo", limit: 345, page: 345)
        let expectation = expectation(description: "waiting for getLovedTracks")

        apiClientMock.error = RuntimeError("Any error")

        instance.getTopArtists(params: params) { result in
            switch(result) {
            case .success(_):
                XCTFail("Expected to fail, but it succeed.")
            case .failure(_):
                XCTAssert(true)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 3)
    }

    // getWeeklyArtistChart

    fileprivate func validateUserWeeklyArtistChartSuccessResponse(_ artists: (CollectionList<UserWeeklyArtistChart>)) {
        XCTAssertEqual(artists.items[0].mbid, "artist-0-mbid")
        XCTAssertEqual(artists.items[0].url.absoluteString, "https://artists.com/artist-0")
        XCTAssertEqual(artists.items[0].rank, 1)
        XCTAssertEqual(artists.items[0].playcount, 7600)
        
        XCTAssertEqual(artists.items[1].mbid, "artist-1-mbid")
        XCTAssertEqual(artists.items[1].url.absoluteString, "https://artists.com/artist-1")
        XCTAssertEqual(artists.items[1].rank, 2)
        XCTAssertEqual(artists.items[1].playcount, 7610)
    }
    
    func test_getWeeklyArtistChart_success() async throws {
        let jsonURL = Bundle.module.url(
            forResource: "Resources/user.getWeeklyArtistChart",
            withExtension: "json"
        )!

        let fakeData = try Data(contentsOf: jsonURL)
        let params = UserWeeklyChartParams(user: "user", from: 123412, to: 53452)

        apiClientMock.data = fakeData
        apiClientMock.response = Constants.RESPONSE_200_OK
        
        let artists = try await instance.getWeeklyArtistChart(params: params)

        validateUserWeeklyArtistChartSuccessResponse(artists)

        XCTAssertEqual(apiClientMock.asyncPostCalls.count, 0)
        XCTAssertEqual(apiClientMock.asyncGetCalls.count, 1)
        XCTAssertEqual(apiClientMock.asyncGetCalls[0].headers, nil)

        XCTAssertTrue(
            Util.areSameURL(
                apiClientMock.asyncGetCalls[0].url.absoluteString,
                "https://ws.audioscrobbler.com/2.0?method=user.getweeklyartistchart&user=\(params.user)&from=\(params.from)&to=\(params.to)&api_key=\(Constants.API_KEY)&format=json"
            )
        )
    }
    
    func test_getWeeklyArtistChart_success() throws {
        let jsonURL = Bundle.module.url(
            forResource: "Resources/user.getWeeklyArtistChart",
            withExtension: "json"
        )!

        let fakeData = try Data(contentsOf: jsonURL)
        let params = UserWeeklyChartParams(user: "user", from: 123412, to: 53452)

        apiClientMock.data = fakeData
        apiClientMock.response = Constants.RESPONSE_200_OK

        let expectation = expectation(description: "Waiting for getWeeklyArtistChart")

        instance.getWeeklyArtistChart(params: params) { result in
            switch (result) {
            case .success(let artists):
                self.validateUserWeeklyArtistChartSuccessResponse(artists)
            case .failure(let error):
                XCTFail("Expected to be a success but got a failure with \(error)")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 3)

        XCTAssertEqual(apiClientMock.postCalls.count, 0)
        XCTAssertEqual(apiClientMock.getCalls.count, 1)
        XCTAssertEqual(apiClientMock.getCalls[0].headers, nil)

        XCTAssertTrue(
            Util.areSameURL(
                apiClientMock.getCalls[0].url.absoluteString,
                "https://ws.audioscrobbler.com/2.0?method=user.getweeklyartistchart&user=\(params.user)&from=\(params.from)&to=\(params.to)&api_key=\(Constants.API_KEY)&format=json"
            )
        )
    }

    // getTopAlbums

    fileprivate func validateUserTopAlbumsSuccessResponse(_ entity: (CollectionPage<UserTopAlbum>)) {
        XCTAssertEqual(entity.items.count, 5)
        XCTAssertEqual(entity.items[0].artist.name, "The Ataris")
        
        XCTAssertEqual(
            entity.items[0].artist.mbid,
            "57805d77-f947-4851-b7fb-78baad154451"
        )
        
        XCTAssertEqual(
            entity.items[0].artist.url.absoluteString,
            "https://www.last.fm/music/The+Ataris"
        )
        
        XCTAssertEqual(
            entity.items[0].image.small!.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/34s/baad825eec21da267b92599dc9ed2f66.jpg"
        )
        
        XCTAssertEqual(
            entity.items[0].image.medium!.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/64s/baad825eec21da267b92599dc9ed2f66.jpg"
        )
        
        XCTAssertEqual(
            entity.items[0].image.large!.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/174s/baad825eec21da267b92599dc9ed2f66.jpg"
        )
        
        XCTAssertEqual(
            entity.items[0].image.extraLarge!.absoluteString,
            "https://lastfm.freetls.fastly.net/i/u/300x300/baad825eec21da267b92599dc9ed2f66.jpg"
        )
        
        XCTAssertNil(entity.items[0].image.mega)
        XCTAssertEqual(entity.pagination.page, 1)
        XCTAssertEqual(entity.pagination.perPage, 5)
        XCTAssertEqual(entity.pagination.total, 30448)
        XCTAssertEqual(entity.pagination.totalPages, 6090)
    }
    
    func test_getTopAlbums_success() async throws {
        let fakeDataURL = Bundle.module.url(forResource: "Resources/user.getTopAlbums", withExtension: "json")!
        let fakeData = try Data(contentsOf: fakeDataURL)
        let params = UserTopItemsParams(user: "someUser", limit: 5, page: 12)

        apiClientMock.data = fakeData
        apiClientMock.response = Constants.RESPONSE_200_OK
        
        let entity = try await instance.getTopAlbums(params: params)
        
        validateUserTopAlbumsSuccessResponse(entity)
        
        XCTAssertEqual(apiClientMock.asyncGetCalls.count, 1)
        XCTAssertEqual(apiClientMock.asyncGetCalls[0].headers, nil)

        XCTAssertTrue(
            Util.areSameURL(
                apiClientMock.asyncGetCalls[0].url.absoluteString,
                "https://ws.audioscrobbler.com/2.0?method=user.gettopalbums&user=\(params.user)&period=\(params.period)&limit=\(params.limit)&page=\(params.page)&api_key=\(Constants.API_KEY)&format=json"
            )
        )
    }
    
    func test_getTopAlbums_success() throws {
        let fakeDataURL = Bundle.module.url(forResource: "Resources/user.getTopAlbums", withExtension: "json")!
        let fakeData = try Data(contentsOf: fakeDataURL)
        let params = UserTopItemsParams(user: "someUser", limit: 5, page: 12)
        let expectation = expectation(description: "waiting for getTopAlbums")

        apiClientMock.data = fakeData
        apiClientMock.response = Constants.RESPONSE_200_OK

        instance.getTopAlbums(params: params) { result in
            switch(result) {
            case .success(let entity):
                self.validateUserTopAlbumsSuccessResponse(entity)
            case .failure(let error):
                XCTFail("Expected to succeed, but it fail with error: \(error.localizedDescription)")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 3)
        XCTAssertEqual(apiClientMock.getCalls.count, 1)
        XCTAssertEqual(apiClientMock.getCalls[0].headers, nil)

        XCTAssertTrue(
            Util.areSameURL(
                apiClientMock.getCalls[0].url.absoluteString,
                "https://ws.audioscrobbler.com/2.0?method=user.gettopalbums&user=\(params.user)&period=\(params.period)&limit=\(params.limit)&page=\(params.page)&api_key=\(Constants.API_KEY)&format=json"
            )
        )
    }

    fileprivate func validateUserWeeklyAlbumChartSuccessResponse(_ entity: (CollectionList<UserWeeklyAlbumChart>)) {
        XCTAssertEqual(entity.items.count, 1000)
        
        XCTAssertEqual(
            entity.items[0].artist.mbid,
            "03ad1736-b7c9-412a-b442-82536d63a5c4"
        )
        
        XCTAssertEqual(entity.items[0].artist.name, "Elliott Smith")
        
        XCTAssertEqual(
            entity.items[0].mbid,
            "028eb7db-16a4-4934-b3a8-2462ab50b121"
        )
        
        XCTAssertEqual(
            entity.items[0].url.absoluteString,
            "https://www.last.fm/music/Elliott+Smith/Either%2FOr"
        )
        XCTAssertEqual(entity.items[0].name, "Either/Or")
        XCTAssertEqual(entity.items[0].rank, 1)
        XCTAssertEqual(entity.items[0].playcount, 162)
    }
    
    func test_getWeeklyAlbumChart() async throws {
        let jsonURL = Bundle.module.url(
            forResource: "Resources/user.getWeeklyAlbumChart",
            withExtension: "json"
        )!

        let fakeData = try Data(contentsOf: jsonURL)
        let params = UserWeeklyChartParams(user: "user", from: 123412, to: 53452)

        apiClientMock.data = fakeData
        apiClientMock.response = Constants.RESPONSE_200_OK
        
        let entity = try await instance.getWeeklyAlbumChart(params: params)

        validateUserWeeklyAlbumChartSuccessResponse(entity)

        XCTAssertEqual(apiClientMock.asyncPostCalls.count, 0)
        XCTAssertEqual(apiClientMock.asyncGetCalls.count, 1)
        XCTAssertEqual(apiClientMock.asyncGetCalls[0].headers, nil)

        XCTAssertTrue(
            Util.areSameURL(
                apiClientMock.asyncGetCalls[0].url.absoluteString,
                "https://ws.audioscrobbler.com/2.0?method=user.getweeklyalbumchart&user=\(params.user)&from=\(params.from)&to=\(params.to)&api_key=\(Constants.API_KEY)&format=json"
            )
        )
    }
    
    func test_getWeeklyAlbumChart() throws {
        let jsonURL = Bundle.module.url(
            forResource: "Resources/user.getWeeklyAlbumChart",
            withExtension: "json"
        )!

        let fakeData = try Data(contentsOf: jsonURL)
        let params = UserWeeklyChartParams(user: "user", from: 123412, to: 53452)

        apiClientMock.data = fakeData
        apiClientMock.response = Constants.RESPONSE_200_OK

        let expectation = expectation(description: "Waiting for getWeeklyArtistChart")

        instance.getWeeklyAlbumChart(params: params) { result in
            switch (result) {
            case .success(let entity):
                self.validateUserWeeklyAlbumChartSuccessResponse(entity)
            case .failure(let error):
                XCTFail("Expected to be a success but got a failure with \(error)")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 3)

        XCTAssertEqual(apiClientMock.postCalls.count, 0)
        XCTAssertEqual(apiClientMock.getCalls.count, 1)
        XCTAssertEqual(apiClientMock.getCalls[0].headers, nil)

        XCTAssertTrue(
            Util.areSameURL(
                apiClientMock.getCalls[0].url.absoluteString,
                "https://ws.audioscrobbler.com/2.0?method=user.getweeklyalbumchart&user=\(params.user)&from=\(params.from)&to=\(params.to)&api_key=\(Constants.API_KEY)&format=json"
            )
        )
    }

    fileprivate func validateUserInfoSuccessResponse(_ userInfo: (UserInfo)) {
        XCTAssertEqual(userInfo.name, "pepito")
        XCTAssertEqual(userInfo.age, 0)
        XCTAssertEqual(userInfo.subscriber, false)
        XCTAssertEqual(userInfo.realname, "Jose")
        XCTAssertEqual(userInfo.bootstrap, false)
        XCTAssertEqual(userInfo.playcount, 347575)
        XCTAssertEqual(userInfo.artistCount, 14264)
        XCTAssertEqual(userInfo.playlists, 0)
        XCTAssertEqual(userInfo.trackCount, 55279)
        XCTAssertEqual(userInfo.albumCount, 30492)
        
        XCTAssertEqual(
            userInfo.image.small?.absoluteString,
            "https://images.com/pepito-small.png"
        )
        
        XCTAssertEqual(
            userInfo.image.medium?.absoluteString,
            "https://images.com/pepito-medium.png"
        )
        
        XCTAssertEqual(
            userInfo.image.large?.absoluteString,
            "https://images.com/pepito-large.png"
        )
        
        XCTAssertEqual(
            userInfo.image.extraLarge?.absoluteString,
            "https://images.com/pepito-extralarge.png"
        )
        
        XCTAssertNil(userInfo.image.mega)
        
        var dateComponents = DateComponents()
        dateComponents.year = 2011
        dateComponents.month = 8
        dateComponents.day = 17
        dateComponents.hour = 18
        dateComponents.minute = 28
        dateComponents.second = 10
        dateComponents.timeZone = TimeZone(secondsFromGMT: -4 * 60 * 60)
        
        XCTAssertEqual(userInfo.registered, Calendar.current.date(from: dateComponents))
        XCTAssertEqual(userInfo.country, "Bolivia")
        XCTAssertEqual(userInfo.gender, "n")
        XCTAssertEqual(userInfo.url.absoluteString, "https://pepito.profile")
        XCTAssertEqual(userInfo.type, "user")
    }
    
    func test_getInfo() async throws {
        let jsonURL = Bundle.module.url(
            forResource: "Resources/user.getInfo",
            withExtension: "json"
        )!

        let fakeData = try Data(contentsOf: jsonURL)

        apiClientMock.data = fakeData
        apiClientMock.response = Constants.RESPONSE_200_OK
        
        let userInfo = try await instance.getInfo(user: "pepito")
        
        validateUserInfoSuccessResponse(userInfo)

        XCTAssertTrue(
            Util.areSameURL(
                apiClientMock.asyncGetCalls[0].url.absoluteString,
                "https://ws.audioscrobbler.com/2.0?method=user.getinfo&user=pepito&api_key=\(Constants.API_KEY)&format=json"
            )
        )
    }
    
    func test_getInfo() throws {
        let jsonURL = Bundle.module.url(
            forResource: "Resources/user.getInfo",
            withExtension: "json"
        )!

        let fakeData = try Data(contentsOf: jsonURL)
        let expectation = expectation(description: "Waiting for getInfo")

        apiClientMock.data = fakeData
        apiClientMock.response = Constants.RESPONSE_200_OK

        instance.getInfo(user: "pepito") { result in
            switch (result) {
            case .success(let userInfo):
                self.validateUserInfoSuccessResponse(userInfo)
            case .failure(let error):
                XCTFail("It was supposed to succeed, but it failed with error \(error.localizedDescription)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 3)
        XCTAssertTrue(
            Util.areSameURL(
                apiClientMock.getCalls[0].url.absoluteString,
                "https://ws.audioscrobbler.com/2.0?method=user.getinfo&user=pepito&api_key=\(Constants.API_KEY)&format=json"
            )
        )
    }
    
    fileprivate func validateUserInfoBySessionKeySuccessResponse(_ userInfo: (UserInfo)) {
        XCTAssertEqual(userInfo.name, "pepito")
        XCTAssertEqual(userInfo.age, 0)
        XCTAssertEqual(userInfo.subscriber, false)
        XCTAssertEqual(userInfo.realname, "Jose")
        XCTAssertEqual(userInfo.bootstrap, false)
        XCTAssertEqual(userInfo.playcount, 347575)
        XCTAssertEqual(userInfo.artistCount, 14264)
        XCTAssertEqual(userInfo.playlists, 0)
        XCTAssertEqual(userInfo.trackCount, 55279)
        XCTAssertEqual(userInfo.albumCount, 30492)
        
        XCTAssertEqual(
            userInfo.image.small?.absoluteString,
            "https://images.com/pepito-small.png"
        )
        
        XCTAssertEqual(
            userInfo.image.medium?.absoluteString,
            "https://images.com/pepito-medium.png"
        )
        
        XCTAssertEqual(
            userInfo.image.large?.absoluteString,
            "https://images.com/pepito-large.png"
        )
        
        XCTAssertEqual(
            userInfo.image.extraLarge?.absoluteString,
            "https://images.com/pepito-extralarge.png"
        )
        
        XCTAssertNil(userInfo.image.mega)
        
        var dateComponents = DateComponents()
        dateComponents.year = 2011
        dateComponents.month = 8
        dateComponents.day = 17
        dateComponents.hour = 18
        dateComponents.minute = 28
        dateComponents.second = 10
        dateComponents.timeZone = TimeZone(secondsFromGMT: -4 * 60 * 60)
        
        XCTAssertEqual(userInfo.registered, Calendar.current.date(from: dateComponents))
        XCTAssertEqual(userInfo.country, "Bolivia")
        XCTAssertEqual(userInfo.gender, "n")
        XCTAssertEqual(userInfo.url.absoluteString, "https://pepito.profile")
        XCTAssertEqual(userInfo.type, "user")
    }
    
    func test_getInfoBySessionKey() async throws {
        let jsonURL = Bundle.module.url(
            forResource: "Resources/user.getInfo",
            withExtension: "json"
        )!

        let fakeData = try Data(contentsOf: jsonURL)

        apiClientMock.data = fakeData
        apiClientMock.response = Constants.RESPONSE_200_OK
        
        let userInfo = try await instance.getInfo(sessionKey: "someSessionKey")
        
        validateUserInfoBySessionKeySuccessResponse(userInfo)
        
        XCTAssertEqual(apiClientMock.asyncPostCalls.count, 1)

        let actualBody = String(data: apiClientMock.asyncPostCalls[0].body!, encoding: .utf8)!
        let expectedBody = "sk=someSessionKey&method=user.getinfo&api_key=someAPIKey"
        
        XCTAssertTrue(
            Util.areSameURL(
                "http://somedomain.com/?\(actualBody)",
                "http://somedomain.com/?\(expectedBody)"
            )
        )
        
        XCTAssertEqual(
            apiClientMock.asyncPostCalls[0].headers,
            ["Content-Type": "application/x-www-formurlencoded"]
        )
        
        XCTAssertTrue(
            Util.areSameURL(
                "https://ws.audioscrobbler.com/2.0?format=json",
                apiClientMock.asyncPostCalls[0].url.absoluteString
            )
        )
    }
    
    func test_getInfoBySessionKey() throws {
        let jsonURL = Bundle.module.url(
            forResource: "Resources/user.getInfo",
            withExtension: "json"
        )!

        let fakeData = try Data(contentsOf: jsonURL)
        let expectation = expectation(description: "Waiting for getInfo")

        apiClientMock.data = fakeData
        apiClientMock.response = Constants.RESPONSE_200_OK
        
        try instance.getInfo(sessionKey: "someSessionKey") { result in
            switch (result) {
            case .success(let userInfo):
                self.validateUserInfoBySessionKeySuccessResponse(userInfo)
            case .failure(let error):
                XCTFail("It was supposed to succeed, but it failed with error \(error.localizedDescription)")
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
        XCTAssertEqual(apiClientMock.postCalls.count, 1)

        let actualBody = String(data: apiClientMock.postCalls[0].body!, encoding: .utf8)!
        let expectedBody = "sk=someSessionKey&method=user.getinfo&api_key=someAPIKey"
        
        XCTAssertTrue(
            Util.areSameURL(
                "http://somedomain.com/?\(actualBody)",
                "http://somedomain.com/?\(expectedBody)"
            )
        )
        
        XCTAssertEqual(
            apiClientMock.postCalls[0].headers,
            ["Content-Type": "application/x-www-formurlencoded"]
        )
        
        XCTAssertTrue(
            Util.areSameURL(
                "https://ws.audioscrobbler.com/2.0?format=json",
                apiClientMock.postCalls[0].url.absoluteString
            )
        )
    }

    fileprivate func validateUserFriendsSuccessResponse(_ friends: (CollectionPage<UserPublicInfo>)) {
        XCTAssertEqual(friends.items.count, 2)
        XCTAssertEqual(friends.pagination.page, 1)
        XCTAssertEqual(friends.pagination.perPage, 2)
        XCTAssertEqual(friends.pagination.total, 26)
        XCTAssertEqual(friends.pagination.totalPages, 13)
        
        XCTAssertEqual(friends.items[0].name, "User 0")
        XCTAssertEqual(friends.items[0].url.absoluteString, "https://users.com/user-0")
        XCTAssertEqual(friends.items[0].country, "Country 0")
        XCTAssertEqual(friends.items[0].playlists, 0)
        XCTAssertEqual(friends.items[0].playcount, 2300)
        XCTAssertEqual(friends.items[0].image.small?.absoluteString, "https://images.com/user-0-s.png")
        XCTAssertEqual(friends.items[0].image.medium?.absoluteString, "https://images.com/user-0-m.png")
        XCTAssertEqual(friends.items[0].image.large?.absoluteString, "https://images.com/user-0-l.png")
        XCTAssertEqual(friends.items[0].image.extraLarge?.absoluteString, "https://images.com/user-0-xl.png")
        XCTAssertNil(friends.items[0].image.mega)
        
        let dateComponents = DateComponents(
            calendar: Calendar.current,
            timeZone: TimeZone(secondsFromGMT: 0),
            year: 2014,
            month: 12,
            day: 16,
            hour: 23,
            minute: 20,
            second: 58
        )
        
        XCTAssertEqual(friends.items[0].registered, Calendar.current.date(from: dateComponents))
        XCTAssertEqual(friends.items[0].realname, "User 0 realname")
        XCTAssertEqual(friends.items[0].subscriber, false)
        XCTAssertFalse(friends.items[0].bootstrap)
        XCTAssertEqual(friends.items[0].type, "user")
        
        XCTAssertEqual(friends.items[1].name, "User 1")
        XCTAssertEqual(friends.items[1].url.absoluteString, "https://users.com/user-1")
        XCTAssertEqual(friends.items[1].country, "Country 1")
        XCTAssertEqual(friends.items[1].playlists, 1)
        XCTAssertEqual(friends.items[1].playcount, 2310)
        XCTAssertEqual(friends.items[1].image.small?.absoluteString, "https://images.com/user-1-s.png")
        XCTAssertEqual(friends.items[1].image.medium?.absoluteString, "https://images.com/user-1-m.png")
        XCTAssertEqual(friends.items[1].image.large?.absoluteString, "https://images.com/user-1-l.png")
        XCTAssertEqual(friends.items[1].image.extraLarge?.absoluteString, "https://images.com/user-1-xl.png")
        XCTAssertNil(friends.items[0].image.mega)
        XCTAssertEqual(friends.items[1].registered, Date(timeIntervalSince1970: 1588410855))
        XCTAssertEqual(friends.items[1].realname, "User 1 realname")
        XCTAssertEqual(friends.items[1].subscriber, true)
        XCTAssertFalse(friends.items[1].bootstrap)
        XCTAssertEqual(friends.items[1].type, "subscriber")
    }
    
    func test_getFriends_success() async throws {
        let jsonURL = Bundle.module.url(
            forResource: "Resources/user.getFriends",
            withExtension: "json"
        )!

        let fakeData = try Data(contentsOf: jsonURL)
        let params = SearchParams(term: "pepiro", limit: 2, page: 1)

        apiClientMock.response = Constants.RESPONSE_200_OK
        apiClientMock.data = fakeData
        
        let friends = try await instance.getFriends(params: params)

        validateUserFriendsSuccessResponse(friends)
        
        XCTAssertEqual(apiClientMock.asyncGetCalls.count, 1)
        XCTAssertEqual(apiClientMock.asyncGetCalls[0].headers, nil)

        XCTAssertTrue(
            Util.areSameURL(
                "https://ws.audioscrobbler.com/2.0?method=user.getfriends&format=json&api_key=someAPIKey&page=1&user=pepiro&limit=2",
                apiClientMock.asyncGetCalls[0].url.absoluteString
            )
        )
    }
    
    func test_getFriends_success() throws {
        let jsonURL = Bundle.module.url(
            forResource: "Resources/user.getFriends",
            withExtension: "json"
        )!

        let fakeData = try Data(contentsOf: jsonURL)
        let params = SearchParams(term: "pepiro", limit: 2, page: 1)
        let expectation = expectation(description: "Waiting for getFriends()")

        apiClientMock.response = Constants.RESPONSE_200_OK
        apiClientMock.data = fakeData

        instance.getFriends(params: params) { result in
            switch (result) {
            case .success(let friends):
                self.validateUserFriendsSuccessResponse(friends)
            case .failure(let error):
                XCTFail("Expected to succeed, but it failed, error: \(error.localizedDescription)")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 3)
        XCTAssertEqual(apiClientMock.getCalls.count, 1)
        XCTAssertEqual(apiClientMock.getCalls[0].headers, nil)

        XCTAssertTrue(
            Util.areSameURL(
                "https://ws.audioscrobbler.com/2.0?method=user.getfriends&format=json&api_key=someAPIKey&page=1&user=pepiro&limit=2",
                apiClientMock.getCalls[0].url.absoluteString
            )
        )
    }

    fileprivate func validateUserWeeklyChartListSuccessResponse(_ chartList: (CollectionList<ChartDateRange>)) {
        XCTAssertEqual(chartList.items.count, 2)
        XCTAssertEqual(chartList.items[0].from, 1108296000)
        XCTAssertEqual(chartList.items[0].to, 1108900800)
        
        XCTAssertEqual(chartList.items[1].from, 1108900800)
        XCTAssertEqual(chartList.items[1].to, 1109505600)
    }
    
    func test_getWeeklyChartList_success() async throws {
        let jsonURL = Bundle.module.url(
            forResource: "Resources/user.getWeeklyChartList",
            withExtension: "json"
        )!

        let fakeData = try Data(contentsOf: jsonURL)

        apiClientMock.response = Constants.RESPONSE_200_OK
        apiClientMock.data = fakeData
        
        let chartList = try await instance.getWeeklyChartList(user: "pepiro")

        validateUserWeeklyChartListSuccessResponse(chartList)

        XCTAssertEqual(apiClientMock.asyncGetCalls.count, 1)
        XCTAssertEqual(apiClientMock.asyncGetCalls[0].headers, nil)

        XCTAssertTrue(
            Util.areSameURL(
                "https://ws.audioscrobbler.com/2.0?format=json&user=pepiro&method=user.getweeklychartlist&api_key=someAPIKey",
                apiClientMock.asyncGetCalls[0].url.absoluteString
            )
        )
    }
    
    func test_getWeeklyChartList_success() throws {
        let jsonURL = Bundle.module.url(
            forResource: "Resources/user.getWeeklyChartList",
            withExtension: "json"
        )!

        let fakeData = try Data(contentsOf: jsonURL)
        let expectation = expectation(description: "Waiting for getWeeklyChartList()")

        apiClientMock.response = Constants.RESPONSE_200_OK
        apiClientMock.data = fakeData

        instance.getWeeklyChartList(user: "pepiro") { result in
            switch (result) {
            case .success(let chartList):
                self.validateUserWeeklyChartListSuccessResponse(chartList)
            case .failure(let error):
                XCTFail("Expected to succeed, but it failed, error: \(error.localizedDescription)")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 3)
        XCTAssertEqual(apiClientMock.getCalls.count, 1)
        XCTAssertEqual(apiClientMock.getCalls[0].headers, nil)

        XCTAssertTrue(
            Util.areSameURL(
                "https://ws.audioscrobbler.com/2.0?format=json&user=pepiro&method=user.getweeklychartlist&api_key=someAPIKey",
                apiClientMock.getCalls[0].url.absoluteString
            )
        )
    }
}
