import Foundation

public struct SearchResults<T: Decodable>: Decodable {

    public struct Pagination: Decodable {
        public let startPage: UInt
        public let totalResults: UInt
        public let startIndex: UInt
        public let itemsPerPage: UInt

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.NestedCodingKeys.self)

            let openQueryContainer = try container.nestedContainer(
                keyedBy: CodingKeys.NestedCodingKeys.OpenSearchKeys.self,
                forKey: .query
            )

            let startPageString = try openQueryContainer.decode(String.self, forKey: .startPage)
            let totalResultsString = try container.decode(String.self, forKey: .totalResults)
            let startIndexString = try container.decode(String.self, forKey: .startIndex)
            let itemsPerPageString = try container.decode(String.self, forKey: .itemsPerPage)

            guard
                let startPage = UInt(startPageString),
                let totalResults = UInt(totalResultsString),
                let startIndex = UInt(startIndexString),
                let itemsPerPage = UInt(itemsPerPageString)
            else {
                throw RuntimeError("Can't decode startPage, totalResults, startIndex or itemsPerPage")
            }

            self.startPage = startPage
            self.totalResults = totalResults
            self.startIndex = startIndex
            self.itemsPerPage = itemsPerPage
        }
    }

    public let items: [T]
    public let pagination: Pagination

    private enum CodingKeys: String, CodingKey {
        case results

        enum NestedCodingKeys: String, CodingKey {
            case query = "opensearch:Query"
            case totalResults = "opensearch:totalResults"
            case startIndex = "opensearch:startIndex"
            case itemsPerPage = "opensearch:itemsPerPage"

            enum OpenSearchKeys: String, CodingKey {
                case startPage
            }
        }

    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let resultsContainer = try container.nestedContainer(
            keyedBy: StringCodingKeys.self,
            forKey: .results
        )

        self.pagination = try container.decode(Pagination.self, forKey: .results)

        guard let subcontainerKey = resultsContainer.allKeys.first(where: { key in
            return ![
                "opensearch:Query",
                "opensearch:totalResults",
                "opensearch:startIndex",
                "opensearch:itemsPerPage",
                "@attr"
            ].contains(key.stringValue)
        }) else {
            throw RuntimeError("Can't find key for subcontainer")
        }

        let subcontainer = try resultsContainer.nestedContainer(
            keyedBy: StringCodingKeys.self,
            forKey: subcontainerKey
        )

        guard let itemsKey = subcontainer.allKeys.first else {
            throw RuntimeError("Can't find key for items")
        }

        self.items = try subcontainer.decode([T].self, forKey: itemsKey)
    }

}