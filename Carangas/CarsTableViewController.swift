
import UIKit

class CarsTableViewController: UITableViewController {
    
    var cars: [Car] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        REST.loadCars(onComplete: { (cars) in
            self.cars = cars
            // Toda manipulacao de tela deve ser executada na thread principal e dataTask nao e executada na main
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }) { (error) in
            print(error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewSegue" {
            let vc = segue.destination as! CarViewController
            vc.car = cars[tableView.indexPathForSelectedRow!.row]
        }
    }
    
    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cars.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = cars[indexPath.row].name
        cell.detailTextLabel?.text = cars[indexPath.row].brand
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            REST.deleteCar(with: cars[indexPath.row]) { (success) in
                self.cars.remove(at: indexPath.row)
                DispatchQueue.main.async {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
    }
}
