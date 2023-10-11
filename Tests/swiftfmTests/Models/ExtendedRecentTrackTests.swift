//
//  ExtendedRecentTrackTests.swift
//  
//
//  Created by Daniel on 10/10/23.
//

import XCTest
@testable import swiftfm

class ExtendedRecentTrackTests: XCTestCase {

    static private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy, HH:mm"

        return formatter
    }()

    static private let defaultValues: [String: Any] = [
        "artistMBID": "someArtistMBID",
        "artistName": "someArtistName",
        "artistURL": "https://someartist.com",
        "artistImageSmall": "https://images.net/artistImageSmall.jpg",
        "artistImageMedium": "https://images.net/artistImageMedium.jpg",
        "artistImageLarge": "https://images.net/artistImageLarge.jpg",
        "artistImageExtraLarge": "https://images.net/artistImageExtraLarge.jpg",
        "streamable": false,
        "imageSmall": "https://some.sm/image.jpg",
        "imageMedium": "https://some.md/image.jpg",
        "imageLarge": "https://some.lg/image.jpg",
        "imageExtraLarge": "http://some.xl/image.jpg",
        "mbid": "someMBID",
        "albumMBID": "someAlbumMBID",
        "albumName": "someAlbumName",
        "name": "someTrackName",
        "url": "https://some.track/url",
        "nowPlaying": false,
        "dateUTS": "1696622288",
        "dateText": "06 Oct 2023, 15:58",
        "loved": true
    ]

    static private func generateJSON(
        artistMBID: String = defaultValues["artistMBID"] as! String,
        artistName: String = defaultValues["artistName"] as! String,
        artistURL: String = defaultValues["artistURL"] as! String,
        artistImageSmall: String = defaultValues["artistImageSmall"] as! String,
        artistImageMedium: String = defaultValues["artistImageMedium"] as! String,
        artistImageLarge: String = defaultValues["artistImageLarge"] as! String,
        artistImageExtraLarge: String = defaultValues["artistImageExtraLarge"] as! String,
        streamable: Bool = defaultValues["streamable"] as! Bool,
        imageSmall: String = defaultValues["imageSmall"] as! String,
        imageMedium: String = defaultValues["imageMedium"] as! String,
        imageLarge: String = defaultValues["imageLarge"] as! String,
        imageExtraLarge: String = defaultValues["imageExtraLarge"] as! String,
        mbid: String = defaultValues["mbid"] as! String,
        albumMBID: String = defaultValues["albumMBID"] as! String,
        albumName: String = defaultValues["albumName"] as! String,
        name: String = defaultValues["name"] as! String,
        url: String = defaultValues["url"] as! String,
        nowPlaying: Bool = defaultValues["nowPlaying"] as! Bool,
        dateUTS: String? = defaultValues["dateUTS"] as? String,
        dateText: String? = defaultValues["dateText"] as? String,
        loved: Bool = defaultValues["loved"] as! Bool
    ) -> Data {
        return """
{
  "artist": {
    "url": "\(artistURL)",
    "name": "\(artistName)",
    "image": [
      {
        "size": "small",
        "#text": "\(artistImageSmall)"
      },
      {
        "size": "medium",
        "#text": "\(artistImageMedium)"
      },
      {
        "size": "large",
        "#text": "\(artistImageLarge)"
      },
      {
        "size": "extralarge",
        "#text": "\(artistImageExtraLarge)"
      }
    ],
    "mbid": "\(artistMBID)"
  },
  "streamable": "\(streamable ? 1 : 0)",
  "image": [
    {
      "size": "small",
      "#text": "\(imageSmall)"
    },
    {
      "size": "medium",
      "#text": "\(imageMedium)"
    },
    {
      "size": "large",
      "#text": "\(imageLarge)"
    },
    {
      "size": "extralarge",
      "#text": "\(imageExtraLarge)"
    }
  ],
  "mbid": "\(mbid)",
  "album": {
    "mbid": "\(albumMBID)",
    "#text": "\(albumName)"
  },
  "name": "\(name)",
  \(
    dateUTS != nil && dateText != nil
    ? """
    "date": {
      "uts": "\(dateUTS!)",
      "#text": "\(dateText!)"
    },
    """
    : ""
  )
  \(
    nowPlaying
    ? """
    "@attr": {
        "nowplaying": "true"
    },
    """
    : ""
  )
  "url": "\(url)",
  "loved": "\(loved ? "1" : "0")"
}
""".data(using: .utf8)!
    }

    func testSuccessfulDefaultDecoding() throws {
        let data = Self.generateJSON()
        let recentTrack = try JSONDecoder().decode(ExtendedRecentTrack.self, from: data)

        XCTAssertEqual(
            recentTrack.mbid,
            Self.defaultValues["mbid"] as! String
        )
        XCTAssertEqual(recentTrack.name, Self.defaultValues["name"] as! String)
        XCTAssertEqual(
            recentTrack.artist.mbid,
            Self.defaultValues["artistMBID"] as! String
        )
        XCTAssertEqual(recentTrack.artist.name, Self.defaultValues["artistName"] as! String)

        let unwrappedArtistImageSmall = try XCTUnwrap(recentTrack.artist.images.small)
        XCTAssertEqual(unwrappedArtistImageSmall.absoluteString, Self.defaultValues["artistImageSmall"] as! String)

        let unwrappedArtistImageMedium = try XCTUnwrap(recentTrack.artist.images.medium)
        XCTAssertEqual(unwrappedArtistImageMedium.absoluteString, Self.defaultValues["artistImageMedium"] as! String)

        let unwrappedArtistImageLarge = try XCTUnwrap(recentTrack.artist.images.large)
        XCTAssertEqual(unwrappedArtistImageLarge.absoluteString, Self.defaultValues["artistImageLarge"] as! String)

        let unwrappedArtistImageExtraLarge = try XCTUnwrap(recentTrack.artist.images.extraLarge)
        XCTAssertEqual(unwrappedArtistImageExtraLarge.absoluteString, Self.defaultValues["artistImageExtraLarge"] as! String)

        XCTAssertEqual(recentTrack.album.mbid, Self.defaultValues["albumMBID"] as! String)
        XCTAssertEqual(recentTrack.album.name, Self.defaultValues["albumName"] as! String)
        XCTAssertEqual(recentTrack.url.absoluteString, Self.defaultValues["url"] as! String)

        let unwrappedDate = try XCTUnwrap(recentTrack.date)
        let timestamp = Double(Int(Self.defaultValues["dateUTS"] as! String)!)
        let date = Date(timeIntervalSince1970: timestamp)
        XCTAssertEqual(unwrappedDate, date)

        let unwrappedImageSmall = try XCTUnwrap(recentTrack.images.small)
        XCTAssertEqual(unwrappedImageSmall.absoluteString, Self.defaultValues["imageSmall"] as! String)

        let unwrappedImageMedium = try XCTUnwrap(recentTrack.images.medium)
        XCTAssertEqual(unwrappedImageMedium.absoluteString, Self.defaultValues["imageMedium"] as! String)

        let unwrappedImageLarge = try XCTUnwrap(recentTrack.images.large)
        XCTAssertEqual(unwrappedImageLarge.absoluteString, Self.defaultValues["imageLarge"] as! String)

        let unwrappedImageExtraLarge = try XCTUnwrap(recentTrack.images.extraLarge)
        XCTAssertEqual(unwrappedImageExtraLarge.absoluteString, Self.defaultValues["imageExtraLarge"] as! String)

        XCTAssertEqual(
            recentTrack.streamable,
            Self.defaultValues["streamable"] as! Bool
        )
        XCTAssertEqual(
            recentTrack.nowPlaying,
            Self.defaultValues["nowPlaying"] as! Bool
        )
    }

    func testSuccessfulDecodingStreamable() throws {
        let data = Self.generateJSON(streamable: true)
        let recentTrack = try JSONDecoder().decode(ExtendedRecentTrack.self, from: data)

        XCTAssertEqual(recentTrack.streamable, true)
    }

    func testSuccessfulDecodingWithNoDate() throws {
        let data = Self.generateJSON(dateUTS: nil, dateText: nil)
        let recentTrack = try JSONDecoder().decode(ExtendedRecentTrack.self, from: data)

        XCTAssertNil(recentTrack.date)
    }

    func testSuccesfulDecodingNowPlaying() throws {
        let data = Self.generateJSON(nowPlaying: true)
        let recentTrack = try JSONDecoder().decode(ExtendedRecentTrack.self, from: data)

        XCTAssertTrue(recentTrack.nowPlaying)
    }

    func testSuccessDecodingAsNotLovedTrack() throws {
        let data = Self.generateJSON(loved: false)
        let recentTrack = try JSONDecoder().decode(ExtendedRecentTrack.self, from: data)

        XCTAssertFalse(recentTrack.loved)
    }

    func testFailDecodingDueIncorrectDate() throws {
        let data = Self.generateJSON(dateUTS: "hello this is not a timestamp", dateText: "this is not a date string")
        XCTAssertThrowsError(
            try JSONDecoder().decode(ExtendedRecentTrack.self, from: data),
            "A RuntimeError with \"Invalid Timestamp\" should be have been thrown") { error in
            XCTAssertTrue(error is RuntimeError)
        }
    }
}