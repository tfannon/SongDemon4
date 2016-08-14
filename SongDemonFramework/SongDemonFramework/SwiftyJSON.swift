//  SwiftyJSON.swift
//
//  Copyright (c) 2014 Ruoyu Fu, Pinglin Tang
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

// MARK: - Error

///Error domain
let ErrorDomain: String = "SwiftyJSONErrorDomain"

///Error code
let ErrorUnsupportedType: Int = 999
let ErrorIndexOutOfBounds: Int = 900
let ErrorWrongType: Int = 901
let ErrorNotExist: Int = 500
let ErrorInvalidJSON: Int = 490

// MARK: - JSON Type

/**
JSON's type definitions.

See http://www.json.org
*/
enum Type :Int{

    case number
    case string
    case bool
    case array
    case dictionary
    case null
    case unknown
}

// MARK: - JSON Base

struct JSON {

    /**
    Creates a JSON using the data.

    - parameter data:  The NSData used to convert to json.Top level object in data is an NSArray or NSDictionary
    - parameter opt:   The JSON serialization reading options. `.AllowFragments` by default.
    - parameter error: error The NSErrorPointer used to return the error. `nil` by default.

    - returns: The created JSON
    */
    init(data:Data, options opt: JSONSerialization.ReadingOptions = .allowFragments, error: NSErrorPointer? = nil) {
        do {
            let object: AnyObject = try JSONSerialization.jsonObject(with: data, options: opt)
            self.init(object)
        } catch let aError as NSError {
            if error != nil {
                error??.pointee = aError
            }
            self.init(NSNull())
        }
    }

    /**
     Create a JSON from JSON string
    - parameter string: Normal json string like '{"a":"b"}'

    - returns: The created JSON
    */
    static func parse(_ string:String) -> JSON {
        return string.data(using: String.Encoding.utf8)
            .flatMap({JSON(data: $0)}) ?? JSON(NSNull())
    }

    /**
    Creates a JSON using the object.

    - parameter object:  The object must have the following properties: All objects are NSString/String, NSNumber/Int/Float/Double/Bool, NSArray/Array, NSDictionary/Dictionary, or NSNull; All dictionary keys are NSStrings/String; NSNumbers are not NaN or infinity.

    - returns: The created JSON
    */
    init(_ object: AnyObject) {
        self.object = object
    }

    /**
    Creates a JSON from a [JSON]

    - parameter jsonArray: A Swift array of JSON objects

    - returns: The created JSON
    */
    init(_ jsonArray:[JSON]) {
        self.init(jsonArray.map { $0.object })
    }

    /**
    Creates a JSON from a [String: JSON]

    - parameter jsonDictionary: A Swift dictionary of JSON objects

    - returns: The created JSON
    */
    init(_ jsonDictionary:[String: JSON]) {
        var dictionary = [String: AnyObject](minimumCapacity: jsonDictionary.count)
        for (key, json) in jsonDictionary {
            dictionary[key] = json.object
        }
        self.init(dictionary)
    }

    /// Private object
    private var rawArray: [AnyObject] = []
    private var rawDictionary: [String : AnyObject] = [:]
    private var rawString: String = ""
    private var rawNumber: NSNumber = 0
    private var rawNull: NSNull = NSNull()
    /// Private type
    private var _type: Type = .null
    /// prviate error
    private var _error: NSError? = nil

    /// Object in JSON
    var object: AnyObject {
        get {
            switch self.type {
            case .array:
                return self.rawArray
            case .dictionary:
                return self.rawDictionary
            case .string:
                return self.rawString
            case .number:
                return self.rawNumber
            case .bool:
                return self.rawNumber
            default:
                return self.rawNull
            }
        }
        set {
            _error = nil
            switch newValue {
            case let number as NSNumber:
                if number.isBool {
                    _type = .bool
                } else {
                    _type = .number
                }
                self.rawNumber = number
            case  let string as String:
                _type = .string
                self.rawString = string
            case  _ as NSNull:
                _type = .null
            case let array as [AnyObject]:
                _type = .array
                self.rawArray = array
            case let dictionary as [String : AnyObject]:
                _type = .dictionary
                self.rawDictionary = dictionary
            default:
                _type = .unknown
                _error = NSError(domain: ErrorDomain, code: ErrorUnsupportedType, userInfo: [NSLocalizedDescriptionKey: "It is a unsupported type"])
            }
        }
    }

    /// json type
    var type: Type { get { return _type } }

    /// Error in JSON
    var error: NSError? { get { return self._error } }

    /// The static null json
    @available(*, unavailable, renamed:"null")
    static var nullJSON: JSON { get { return null } }
    static var null: JSON { get { return JSON(NSNull()) } }
}

enum JSONIndex:Comparable {
    case array(Int)
    case dictionary(DictionaryIndex<String, JSON>)
    case null
}

func ==(lhs: JSONIndex, rhs: JSONIndex) -> Bool {
    switch (lhs, rhs) {
    case (.array(let left), .array(let right)):
        return left == right
    case (.dictionary(let left), .dictionary(let right)):
        return left == right
    default:
        return false
    }
}

func <(lhs: JSONIndex, rhs: JSONIndex) -> Bool {
    switch (lhs, rhs) {
    case (.array(let left), .array(let right)):
        return left < right
    case (.dictionary(let left), .dictionary(let right)):
        return left < right
    default:
        return false
    }
}


extension JSON: Collection{

    typealias Index = JSONIndex

    var startIndex: Index{
        switch type {
        case .array:
            return .array(rawArray.startIndex)
        case .dictionary:
            return .dictionary(dictionaryValue.startIndex)
        default:
            return .null
        }
    }

    var endIndex: Index{
        switch type {
        case .array:
            return .array(rawArray.endIndex)
        case .dictionary:
            return .dictionary(dictionaryValue.endIndex)
        default:
            return .null
        }
    }

    func index(after i: Index) -> Index {
        switch i {
        case .array(let idx):
            return .array(rawArray.index(after: idx))
        case .dictionary(let idx):
            return .dictionary(dictionaryValue.index(after: idx))
        default:
            return .null
        }

    }

    subscript (position: Index) -> (String, JSON) {
        switch position {
        case .array(let idx):
            return (String(idx), JSON(self.rawArray[idx]))
        case .dictionary(let idx):
            return dictionaryValue[idx]
        default:
            return ("", JSON.null)
        }
    }


}

// MARK: - Subscript

/**
*  To mark both String and Int can be used in subscript.
*/
enum JSONKey {
    case index(Int)
    case key(String)
}

protocol JSONSubscriptType {
    var jsonKey:JSONKey { get }
}

extension Int: JSONSubscriptType {
    var jsonKey:JSONKey {
        return JSONKey.index(self)
    }
}

extension String: JSONSubscriptType {
    var jsonKey:JSONKey {
        return JSONKey.key(self)
    }
}

extension JSON {

    /// If `type` is `.Array`, return json whose object is `array[index]`, otherwise return null json with error.
    private subscript(index index: Int) -> JSON {
        get {
            if self.type != .array {
                var r = JSON.null
                r._error = self._error ?? NSError(domain: ErrorDomain, code: ErrorWrongType, userInfo: [NSLocalizedDescriptionKey: "Array[\(index)] failure, It is not an array"])
                return r
            } else if index >= 0 && index < self.rawArray.count {
                return JSON(self.rawArray[index])
            } else {
                var r = JSON.null
                r._error = NSError(domain: ErrorDomain, code:ErrorIndexOutOfBounds , userInfo: [NSLocalizedDescriptionKey: "Array[\(index)] is out of bounds"])
                return r
            }
        }
        set {
            if self.type == .array {
                if self.rawArray.count > index && newValue.error == nil {
                    self.rawArray[index] = newValue.object
                }
            }
        }
    }

    /// If `type` is `.Dictionary`, return json whose object is `dictionary[key]` , otherwise return null json with error.
    private subscript(key key: String) -> JSON {
        get {
            var r = JSON.null
            if self.type == .dictionary {
                if let o = self.rawDictionary[key] {
                    r = JSON(o)
                } else {
                    r._error = NSError(domain: ErrorDomain, code: ErrorNotExist, userInfo: [NSLocalizedDescriptionKey: "Dictionary[\"\(key)\"] does not exist"])
                }
            } else {
                r._error = self._error ?? NSError(domain: ErrorDomain, code: ErrorWrongType, userInfo: [NSLocalizedDescriptionKey: "Dictionary[\"\(key)\"] failure, It is not an dictionary"])
            }
            return r
        }
        set {
            if self.type == .dictionary && newValue.error == nil {
                self.rawDictionary[key] = newValue.object
            }
        }
    }

    /// If `sub` is `Int`, return `subscript(index:)`; If `sub` is `String`,  return `subscript(key:)`.
    private subscript(sub sub: JSONSubscriptType) -> JSON {
        get {
            switch sub.jsonKey {
            case .index(let index): return self[index: index]
            case .key(let key): return self[key: key]
            }
        }
        set {
            switch sub.jsonKey {
            case .index(let index): self[index: index] = newValue
            case .key(let key): self[key: key] = newValue
            }
        }
    }

    /**
    Find a json in the complex data structuresby using the Int/String's array.

    - parameter path: The target json's path. Example:

    let json = JSON[data]
    let path = [9,"list","person","name"]
    let name = json[path]

    The same as: let name = json[9]["list"]["person"]["name"]

    - returns: Return a json found by the path or a null json with error
    */
    subscript(path: [JSONSubscriptType]) -> JSON {
        get {
            return path.reduce(self) { $0[sub: $1] }
        }
        set {
            switch path.count {
            case 0:
                return
            case 1:
                self[sub:path[0]].object = newValue.object
            default:
                var aPath = path; aPath.remove(at: 0)
                var nextJSON = self[sub: path[0]]
                nextJSON[aPath] = newValue
                self[sub: path[0]] = nextJSON
            }
        }
    }

    /**
    Find a json in the complex data structures by using the Int/String's array.

    - parameter path: The target json's path. Example:

    let name = json[9,"list","person","name"]

    The same as: let name = json[9]["list"]["person"]["name"]

    - returns: Return a json found by the path or a null json with error
    */
    subscript(path: JSONSubscriptType...) -> JSON {
        get {
            return self[path]
        }
        set {
            self[path] = newValue
        }
    }
}

// MARK: - LiteralConvertible

extension JSON: Swift.StringLiteralConvertible {

    init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }

    init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self.init(value)
    }

    init(unicodeScalarLiteral value: StringLiteralType) {
        self.init(value)
    }
}

extension JSON: Swift.IntegerLiteralConvertible {

    init(integerLiteral value: IntegerLiteralType) {
        self.init(value)
    }
}

extension JSON: Swift.BooleanLiteralConvertible {

    init(booleanLiteral value: BooleanLiteralType) {
        self.init(value)
    }
}

extension JSON: Swift.FloatLiteralConvertible {

    init(floatLiteral value: FloatLiteralType) {
        self.init(value)
    }
}

extension JSON: Swift.DictionaryLiteralConvertible {

    init(dictionaryLiteral elements: (String, AnyObject)...) {
        self.init(elements.reduce([String : AnyObject](minimumCapacity: elements.count)){(dictionary: [String : AnyObject], element:(String, AnyObject)) -> [String : AnyObject] in
            var d = dictionary
            d[element.0] = element.1
            return d
            })
    }
}

extension JSON: Swift.ArrayLiteralConvertible {

    init(arrayLiteral elements: AnyObject...) {
        self.init(elements)
    }
}

extension JSON: Swift.NilLiteralConvertible {

    init(nilLiteral: ()) {
        self.init(NSNull())
    }
}

// MARK: - Raw

extension JSON: Swift.RawRepresentable {

    init?(rawValue: AnyObject) {
        if JSON(rawValue).type == .unknown {
            return nil
        } else {
            self.init(rawValue)
        }
    }

    var rawValue: AnyObject {
        return self.object
    }

    func rawData(options opt: JSONSerialization.WritingOptions = JSONSerialization.WritingOptions(rawValue: 0)) throws -> Data {
        guard JSONSerialization.isValidJSONObject(self.object) else {
            throw NSError(domain: ErrorDomain, code: ErrorInvalidJSON, userInfo: [NSLocalizedDescriptionKey: "JSON is invalid"])
        }

        return try JSONSerialization.data(withJSONObject: self.object, options: opt)
    }

    func rawString(_ encoding: String.Encoding = String.Encoding.utf8, options opt: JSONSerialization.WritingOptions = .prettyPrinted) -> String? {
        switch self.type {
        case .array, .dictionary:
            do {
                let data = try self.rawData(options: opt)
                return String(data: data, encoding: encoding)
            } catch _ {
                return nil
            }
        case .string:
            return self.rawString
        case .number:
            return self.rawNumber.stringValue
        case .bool:
            return self.rawNumber.boolValue.description
        case .null:
            return "null"
        default:
            return nil
        }
    }
}

// MARK: - Printable, DebugPrintable

extension JSON: Swift.CustomStringConvertible, Swift.CustomDebugStringConvertible {

    var description: String {
        if let string = self.rawString(options:.prettyPrinted) {
            return string
        } else {
            return "unknown"
        }
    }

    var debugDescription: String {
        return description
    }
}

// MARK: - Array

extension JSON {

    //Optional [JSON]
    var array: [JSON]? {
        get {
            if self.type == .array {
                return self.rawArray.map{ JSON($0) }
            } else {
                return nil
            }
        }
    }

    //Non-optional [JSON]
    var arrayValue: [JSON] {
        get {
            return self.array ?? []
        }
    }

    //Optional [AnyObject]
    var arrayObject: [AnyObject]? {
        get {
            switch self.type {
            case .array:
                return self.rawArray
            default:
                return nil
            }
        }
        set {
            if let array = newValue {
                self.object = array
            } else {
                self.object = NSNull()
            }
        }
    }
}

// MARK: - Dictionary

extension JSON {

    //Optional [String : JSON]
    var dictionary: [String : JSON]? {
        if self.type == .dictionary {

            return self.rawDictionary.reduce([String : JSON]()) { (dictionary: [String : JSON], element: (String, AnyObject)) -> [String : JSON] in
                var d = dictionary
                d[element.0] = JSON(element.1)
                return d
            }
        } else {
            return nil
        }
    }

    //Non-optional [String : JSON]
    var dictionaryValue: [String : JSON] {
        return self.dictionary ?? [:]
    }

    //Optional [String : AnyObject]
    var dictionaryObject: [String : AnyObject]? {
        get {
            switch self.type {
            case .dictionary:
                return self.rawDictionary
            default:
                return nil
            }
        }
        set {
            if let v = newValue {
                self.object = v
            } else {
                self.object = NSNull()
            }
        }
    }
}

// MARK: - Bool

//extension JSON: Boolean {
extension JSON {

    //Optional bool
    var bool: Bool? {
        get {
            switch self.type {
            case .bool:
                return self.rawNumber.boolValue
            default:
                return nil
            }
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
            } else {
                self.object = NSNull()
            }
        }
    }

    //Non-optional bool
    var boolValue: Bool {
        get {
            switch self.type {
            case .bool, .number, .string:
                return self.object.boolValue
            default:
                return false
            }
        }
        set {
            self.object = NSNumber(value: newValue)
        }
    }
}

// MARK: - String

extension JSON {

    //Optional string
    var string: String? {
        get {
            switch self.type {
            case .string:
                return self.object as? String
            default:
                return nil
            }
        }
        set {
            if let newValue = newValue {
                self.object = NSString(string:newValue)
            } else {
                self.object = NSNull()
            }
        }
    }

    //Non-optional string
    var stringValue: String {
        get {
            switch self.type {
            case .string:
                return self.object as? String ?? ""
            case .number:
                return self.object.stringValue
            case .bool:
                return (self.object as? Bool).map { String($0) } ?? ""
            default:
                return ""
            }
        }
        set {
            self.object = NSString(string:newValue)
        }
    }
}

// MARK: - Number
extension JSON {

    //Optional number
    var number: NSNumber? {
        get {
            switch self.type {
            case .number, .bool:
                return self.rawNumber
            default:
                return nil
            }
        }
        set {
            self.object = newValue ?? NSNull()
        }
    }

    //Non-optional number
    var numberValue: NSNumber {
        get {
            switch self.type {
            case .string:
                let decimal = NSDecimalNumber(string: self.object as? String)
                if decimal == NSDecimalNumber.notANumber {  // indicates parse error
                    return NSDecimalNumber.zero
                }
                return decimal
            case .number, .bool:
                return self.object as? NSNumber ?? NSNumber(value: 0)
            default:
                return NSNumber(value: 0.0)
            }
        }
        set {
            self.object = newValue
        }
    }
}

//MARK: - Null
extension JSON {

    var null: NSNull? {
        get {
            switch self.type {
            case .null:
                return self.rawNull
            default:
                return nil
            }
        }
        set {
            self.object = NSNull()
        }
    }
    func exists() -> Bool{
        if let errorValue = error , errorValue.code == ErrorNotExist{
            return false
        }
        return true
    }
}

//MARK: - URL
extension JSON {

    //Optional URL
    var URL: Foundation.URL? {
        get {
            switch self.type {
            case .string:
                if let encodedString_ = self.rawString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
                    return Foundation.URL(string: encodedString_)
                } else {
                    return nil
                }
            default:
                return nil
            }
        }
        set {
            self.object = newValue?.absoluteString ?? NSNull()
        }
    }
}

// MARK: - Int, Double, Float, Int8, Int16, Int32, Int64

extension JSON {

    var double: Double? {
        get {
            return self.number?.doubleValue
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
            } else {
                self.object = NSNull()
            }
        }
    }

    var doubleValue: Double {
        get {
            return self.numberValue.doubleValue
        }
        set {
            self.object = NSNumber(value: newValue)
        }
    }

    var float: Float? {
        get {
            return self.number?.floatValue
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
            } else {
                self.object = NSNull()
            }
        }
    }

    var floatValue: Float {
        get {
            return self.numberValue.floatValue
        }
        set {
            self.object = NSNumber(value: newValue)
        }
    }

    var int: Int? {
        get {
            return self.number?.intValue
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
            } else {
                self.object = NSNull()
            }
        }
    }

    var intValue: Int {
        get {
            return self.numberValue.intValue
        }
        set {
            self.object = NSNumber(value: newValue)
        }
    }

    var uInt: UInt? {
        get {
            return self.number?.uintValue
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
            } else {
                self.object = NSNull()
            }
        }
    }

    var uIntValue: UInt {
        get {
            return self.numberValue.uintValue
        }
        set {
            self.object = NSNumber(value: newValue)
        }
    }

    var int8: Int8? {
        get {
            return self.number?.int8Value
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
            } else {
                self.object =  NSNull()
            }
        }
    }

    var int8Value: Int8 {
        get {
            return self.numberValue.int8Value
        }
        set {
            self.object = NSNumber(value: newValue)
        }
    }

    var uInt8: UInt8? {
        get {
            return self.number?.uint8Value
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
            } else {
                self.object =  NSNull()
            }
        }
    }

    var uInt8Value: UInt8 {
        get {
            return self.numberValue.uint8Value
        }
        set {
            self.object = NSNumber(value: newValue)
        }
    }

    var int16: Int16? {
        get {
            return self.number?.int16Value
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
            } else {
                self.object =  NSNull()
            }
        }
    }

    var int16Value: Int16 {
        get {
            return self.numberValue.int16Value
        }
        set {
            self.object = NSNumber(value: newValue)
        }
    }

    var uInt16: UInt16? {
        get {
            return self.number?.uint16Value
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
            } else {
                self.object =  NSNull()
            }
        }
    }

    var uInt16Value: UInt16 {
        get {
            return self.numberValue.uint16Value
        }
        set {
            self.object = NSNumber(value: newValue)
        }
    }

    var int32: Int32? {
        get {
            return self.number?.int32Value
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
            } else {
                self.object =  NSNull()
            }
        }
    }

    var int32Value: Int32 {
        get {
            return self.numberValue.int32Value
        }
        set {
            self.object = NSNumber(value: newValue)
        }
    }

    var uInt32: UInt32? {
        get {
            return self.number?.uint32Value
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
            } else {
                self.object =  NSNull()
            }
        }
    }

    var uInt32Value: UInt32 {
        get {
            return self.numberValue.uint32Value
        }
        set {
            self.object = NSNumber(value: newValue)
        }
    }

    var int64: Int64? {
        get {
            return self.number?.int64Value
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
            } else {
                self.object =  NSNull()
            }
        }
    }

    var int64Value: Int64 {
        get {
            return self.numberValue.int64Value
        }
        set {
            self.object = NSNumber(value: newValue)
        }
    }

    var uInt64: UInt64? {
        get {
            return self.number?.uint64Value
        }
        set {
            if let newValue = newValue {
                self.object = NSNumber(value: newValue)
            } else {
                self.object =  NSNull()
            }
        }
    }

    var uInt64Value: UInt64 {
        get {
            return self.numberValue.uint64Value
        }
        set {
            self.object = NSNumber(value: newValue)
        }
    }
}

//MARK: - Comparable
extension JSON : Swift.Comparable {}

func ==(lhs: JSON, rhs: JSON) -> Bool {

    switch (lhs.type, rhs.type) {
    case (.number, .number):
        return lhs.rawNumber == rhs.rawNumber
    case (.string, .string):
        return lhs.rawString == rhs.rawString
    case (.bool, .bool):
        return lhs.rawNumber.boolValue == rhs.rawNumber.boolValue
    case (.array, .array):
        return lhs.rawArray as NSArray == rhs.rawArray as NSArray
    case (.dictionary, .dictionary):
        return lhs.rawDictionary as NSDictionary == rhs.rawDictionary as NSDictionary
    case (.null, .null):
        return true
    default:
        return false
    }
}

func <=(lhs: JSON, rhs: JSON) -> Bool {

    switch (lhs.type, rhs.type) {
    case (.number, .number):
        return lhs.rawNumber <= rhs.rawNumber
    case (.string, .string):
        return lhs.rawString <= rhs.rawString
    case (.bool, .bool):
        return lhs.rawNumber.boolValue == rhs.rawNumber.boolValue
    case (.array, .array):
        return lhs.rawArray as NSArray == rhs.rawArray as NSArray
    case (.dictionary, .dictionary):
        return lhs.rawDictionary as NSDictionary == rhs.rawDictionary as NSDictionary
    case (.null, .null):
        return true
    default:
        return false
    }
}

func >=(lhs: JSON, rhs: JSON) -> Bool {

    switch (lhs.type, rhs.type) {
    case (.number, .number):
        return lhs.rawNumber >= rhs.rawNumber
    case (.string, .string):
        return lhs.rawString >= rhs.rawString
    case (.bool, .bool):
        return lhs.rawNumber.boolValue == rhs.rawNumber.boolValue
    case (.array, .array):
        return lhs.rawArray as NSArray == rhs.rawArray as NSArray
    case (.dictionary, .dictionary):
        return lhs.rawDictionary as NSDictionary == rhs.rawDictionary as NSDictionary
    case (.null, .null):
        return true
    default:
        return false
    }
}

func >(lhs: JSON, rhs: JSON) -> Bool {

    switch (lhs.type, rhs.type) {
    case (.number, .number):
        return lhs.rawNumber > rhs.rawNumber
    case (.string, .string):
        return lhs.rawString > rhs.rawString
    default:
        return false
    }
}

func <(lhs: JSON, rhs: JSON) -> Bool {

    switch (lhs.type, rhs.type) {
    case (.number, .number):
        return lhs.rawNumber < rhs.rawNumber
    case (.string, .string):
        return lhs.rawString < rhs.rawString
    default:
        return false
    }
}

private let trueNumber = NSNumber(value: true)
private let falseNumber = NSNumber(value: false)
private let trueObjCType = String(cString: trueNumber.objCType)
private let falseObjCType = String(cString: falseNumber.objCType)

// MARK: - NSNumber: Comparable

extension NSNumber {
    var isBool:Bool {
        get {
            let objCType = String(cString: self.objCType)
            if (self.compare(trueNumber) == ComparisonResult.orderedSame && objCType == trueObjCType)
                || (self.compare(falseNumber) == ComparisonResult.orderedSame && objCType == falseObjCType){
                    return true
            } else {
                return false
            }
        }
    }
}

func ==(lhs: NSNumber, rhs: NSNumber) -> Bool {
    switch (lhs.isBool, rhs.isBool) {
    case (false, true):
        return false
    case (true, false):
        return false
    default:
        return lhs.compare(rhs) == ComparisonResult.orderedSame
    }
}

func !=(lhs: NSNumber, rhs: NSNumber) -> Bool {
    return !(lhs == rhs)
}

func <(lhs: NSNumber, rhs: NSNumber) -> Bool {

    switch (lhs.isBool, rhs.isBool) {
    case (false, true):
        return false
    case (true, false):
        return false
    default:
        return lhs.compare(rhs) == ComparisonResult.orderedAscending
    }
}

func >(lhs: NSNumber, rhs: NSNumber) -> Bool {

    switch (lhs.isBool, rhs.isBool) {
    case (false, true):
        return false
    case (true, false):
        return false
    default:
        return lhs.compare(rhs) == ComparisonResult.orderedDescending
    }
}

func <=(lhs: NSNumber, rhs: NSNumber) -> Bool {

    switch (lhs.isBool, rhs.isBool) {
    case (false, true):
        return false
    case (true, false):
        return false
    default:
        return lhs.compare(rhs) != ComparisonResult.orderedDescending
    }
}

func >=(lhs: NSNumber, rhs: NSNumber) -> Bool {

    switch (lhs.isBool, rhs.isBool) {
    case (false, true):
        return false
    case (true, false):
        return false
    default:
        return lhs.compare(rhs) != ComparisonResult.orderedAscending
    }
}
