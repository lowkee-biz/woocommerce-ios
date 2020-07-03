import Foundation

/// Mapper: ProductTag List
///
struct ProductTagListMapper: Mapper {
    /// Site Identifier associated to the `ProductTags`s that will be parsed.
    ///
    /// We're injecting this field via `JSONDecoder.userInfo` because SiteID is not returned in any of the ProductTag Endpoints.
    ///
    let siteID: Int64

    let responseType: ResponseType

    /// (Attempts) to convert a dictionary into [ProductTag].
    ///
    func map(response: Data) throws -> [ProductTag] {
        let decoder = JSONDecoder()
        decoder.userInfo = [
            .siteID: siteID
        ]

        switch responseType {
          case .load:
            return try decoder.decode(ProductTagListEnvelope.self, from: response).tags
          case .create:
            return try decoder.decode(ProductTagListBatchCreateEnvelope.self, from: response).tags
          case .delete:
            return try decoder.decode(ProductTagListBatchDeleteEnvelope.self, from: response).tags
        }

//        let decodedResponse = try? decoder.decode(ProductTagListEnvelope.self, from: response)
//        let decodedResponseBatchUpdatedTags = try? decoder.decode(ProductTagListBatchUpdateEnvelope.self, from: response)
//
//        return decodedResponse?.tags ??
//            decodedResponseBatchUpdatedTags?.createdTags ??
//            decodedResponseBatchUpdatedTags?.deletedTags ?? []
    }

    enum ResponseType {
      case load
      case create
      case delete
    }
}


/// ProductTagListEnvelope Disposable Entity:
/// `Load All Products Tags` endpoint returns the products tags in the `data` key.
/// This entity allows us to do parse all the things with JSONDecoder.
///
private struct ProductTagListEnvelope: Decodable {
    let tags: [ProductTag]

    private enum CodingKeys: String, CodingKey {
        case tags = "data"
    }
}


/// ProductTagListBatchCreateEnvelope Disposable Entity:
/// `Batch Create Products Tags` endpoint returns the products tags under the `data` key, nested under `create`  key.
/// This entity allows us to do parse all the things with JSONDecoder.
///
private struct ProductTagListBatchCreateEnvelope: Decodable {
    let tags: [ProductTag]

    init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        let nestedContainer = try? container?.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)

        tags = nestedContainer?.failsafeDecodeIfPresent(Array<ProductTag>.self, forKey: .create) ?? []
    }

    private enum CodingKeys: String, CodingKey {
        case data
        case create
    }
}

/// ProductTagListBatchDeleteEnvelope Disposable Entity:
/// `Batch Delete Products Tags` endpoint returns the products tags under the `data` key, nested under `delete` key.
/// This entity allows us to do parse all the things with JSONDecoder.
///
private struct ProductTagListBatchDeleteEnvelope: Decodable {
    let tags: [ProductTag]

    init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        let nestedContainer = try? container?.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)

        tags = nestedContainer?.failsafeDecodeIfPresent(Array<ProductTag>.self, forKey: .delete) ?? []
    }

    private enum CodingKeys: String, CodingKey {
        case data
        case delete
    }
}
