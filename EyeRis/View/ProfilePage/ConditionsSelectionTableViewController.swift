//
//  ConditionsSelectionTableViewController.swift
//  EyeRis
//
//  Created by SDC-USER on 25/03/26.
//

import UIKit

class ConditionsSelectionTableViewController: UITableViewController {

    var allConditions = Conditions.allCases
    var selectedConditions = Set<Conditions>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
             
          let user = UserManager.shared.currentUser
          selectedConditions = Set(user.eyeHealthData.condition)
          
        tableView.allowsMultipleSelection = true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allConditions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let condition = allConditions[indexPath.row]
        
        // UI text
        cell.textLabel?.text = condition.displayText
        
        // checkmark based on model
        cell.accessoryType = selectedConditions.contains(condition) ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let condition = allConditions[indexPath.row]
        
        if selectedConditions.contains(condition) {
            selectedConditions.remove(condition)
        } else {
            selectedConditions.insert(condition)
        }
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = selectedConditions.contains(condition) ? .checkmark : .none
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        UserManager.shared.updateEyeConditions(Array(selectedConditions))
    }
    

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        updateSelection(at: indexPath, selected: false)
    }

    private func updateSelection(at indexPath: IndexPath, selected: Bool) {
        let condition = allConditions[indexPath.row]
        
        if selected {
            selectedConditions.insert(condition)
        } else {
            selectedConditions.remove(condition)
        }
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = selected ? .checkmark : .none
        }
        
        UserManager.shared.updateEyeConditions(Array(selectedConditions))
    }
}
