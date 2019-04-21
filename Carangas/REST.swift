

import Foundation

enum RESTErrorType {
    case url
    case taskError(error: Error)
    case noResponse
    case noData
    case responseStatusCode(code: Int)
}

enum OperationType {
    case create
    case update
    case delete
}

class REST {
    
    private static var baseURL = "https://carangas.herokuapp.com/cars"
    
    private static let config: URLSessionConfiguration = {
        var con = URLSessionConfiguration.default
        con.allowsCellularAccess = false
        con.httpAdditionalHeaders = ["content-type": "application/json"]
        con.timeoutIntervalForRequest = 30.0
        con.httpMaximumConnectionsPerHost = 5
        return con
    }()
    
    private static let session = URLSession(configuration: config)
    
    static func loadCars(onComplete: @escaping ([Car]) -> Void, onError: @escaping (RESTErrorType) -> Void) {
        guard let url = URL(string: baseURL) else {
            onError(.url)
            return
        }
        
        let dataTask = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            if error == nil {
                guard let response = response as? HTTPURLResponse else {
                    onError(.noResponse)
                    return
                }
                guard response.statusCode == 200 else {
                    onError(.responseStatusCode(code: response.statusCode))
                    return
                }
                guard let data = data else {
                    onError(.noData)
                    return
                }
                let cars = try! JSONDecoder().decode([Car].self, from: data)
                onComplete(cars)
            } else {
                print("Erro na requisicao")
            }
        }
        dataTask.resume()
    }
    
    static func createCar(with car: Car, onComplete: @escaping (Bool) -> Void) {
        executeOperation(with: car, operation: .create, onComplete: onComplete)
    }
    static func updateCar(with car: Car, onComplete: @escaping (Bool) -> Void) {
        executeOperation(with: car, operation: .update, onComplete: onComplete)
    }
    static func deleteCar(with car: Car, onComplete: @escaping (Bool) -> Void) {
        executeOperation(with: car, operation: .delete, onComplete: onComplete)
    }
    
    private static func executeOperation(with car: Car, operation: OperationType, onComplete: @escaping (Bool) -> Void) {
        guard let url = URL(string: car._id != nil ? "\(baseURL)/\(car._id ?? "")" : baseURL) else {
            onComplete(false)
            return
        }
        guard let jsonData = try? JSONEncoder().encode(car) else {
            onComplete(false)
            return
        }
        var request = URLRequest(url: url)
        var method: String
        switch operation {
        case .create:
            method = "POST"
        case .update:
            method = "PUT"
        case .delete:
            method = "DELETE"
        }
        request.httpMethod = method
        request.httpBody = jsonData
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            guard error == nil, let response = response as? HTTPURLResponse, response.statusCode == 200, data != nil else {
                onComplete(false)
                return
            }
            onComplete(true)
        }
        dataTask.resume()
    }
}
