////////////////////////////////////////////////////////////////////////////
//
// Copyright 2020 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

import Realm

/**
 :nodoc:
 **/
public extension ObjectiveCSupport {
    /// Convert an `AnyBSON` to a `RLMBSON`.
    static func convert(object: AnyBSON?) -> RLMBSON? {
        guard let object = object else {
            return nil
        }

        switch object {
        case let .int32(val):
            return val as NSNumber
        case let .int64(val):
            return val as NSNumber
        case let .double(val):
            return val as NSNumber
        case let .string(val):
            return val as NSString
        case let .binary(val):
            return val as NSData
        case let .datetime(val):
            return val as NSDate
        case let .decimal128(val):
            return val as RLMDecimal128
        case let .objectId(val):
            return val as RLMObjectId
        case let .document(val):
            return val.reduce(into: [String: RLMBSON?]()) { (result: inout [String: RLMBSON?], kvp) in
                result[kvp.key] = convert(object: kvp.value) ?? NSNull()
            } as NSDictionary
        case let .array(val):
            return val.map(convert) as NSArray
        case .maxKey:
            return MaxKey()
        case .minKey:
            return MinKey()
        case let .regex(val):
            return val
        case let .bool(val):
            return val as NSNumber
        default:
            return nil
        }
    }

    /// Convert a `RLMBSON` to an `AnyBSON`.
    static func convert(object: RLMBSON?) -> AnyBSON? {
        guard let bson = object else {
            return nil
        }

        switch bson.__bsonType {
        case .null:
            return nil
        case .int32:
            guard let val = bson as? NSNumber else {
                return nil
            }
            return .int32(Int32(val.intValue))
        case .int64:
            guard let val = bson as? NSNumber else {
                return nil
            }
            return .int64(Int64(val.int64Value))
        case .bool:
            guard let val = bson as? NSNumber else {
                return nil
            }
            return .bool(val.boolValue)
        case .double:
            guard let val = bson as? NSNumber else {
                return nil
            }
            return .double(val.doubleValue)
        case .string:
            guard let val = bson as? NSString else {
                return nil
            }
            return .string(val as String)
        case .binary:
            guard let val = bson as? NSData else {
                return nil
            }
            return .binary(val as Data)
        case .timestamp:
            guard let val = bson as? NSDate else {
                return nil
            }
            return .timestamp(val as Date)
        case .datetime:
            guard let val = bson as? NSDate else {
                return nil
            }
            return .datetime(val as Date)
        case .objectId:
            guard let val = bson as? RLMObjectId,
                let oid = try? ObjectId(string: val.stringValue)
            else {
                return nil
            }
            return .objectId(oid)
        case .decimal128:
            guard let val = bson as? RLMDecimal128 else {
                return nil
            }
            return .decimal128(Decimal128(stringLiteral: val.stringValue))
        case .regularExpression:
            guard let val = bson as? NSRegularExpression else {
                return nil
            }
            return .regex(val)
        case .maxKey:
            return .maxKey
        case .minKey:
            return .minKey
        case .document:
            guard let val = bson as? [String: RLMBSON?] else {
                return nil
            }
            return .document(val.reduce(into: [String: AnyBSON?]()) { (result: inout [String: AnyBSON?], kvp) in
                result[kvp.key] = convert(object: kvp.value)
            })
        case .array:
            guard let val = bson as? [RLMBSON?] else {
                return nil
            }
            return .array(val.map(convert))
        default:
            return nil
        }
    }
}
