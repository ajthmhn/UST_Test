//
//  CoreDataHelper.swift
//  UST-Test
//
//  Created by Ajith Mohan on 15/10/24.
//

import CoreData
import Foundation


class CoreDataHelper {
    static let shared = CoreDataHelper()

    // MARK: - Core Data Stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model") // The model name
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()

    // MARK: - Context

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - Save Context

    func saveContext() {
        let context = persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // MARK: - Add Device

    func addDevice(name: String, ipAddress: String, status: String) async throws {
        let context = persistentContainer.viewContext
           
           // Check for existing device
           let fetchRequest: NSFetchRequest<Devices> = Devices.fetchRequest()
           fetchRequest.predicate = NSPredicate(format: "name == %@", name)
           fetchRequest.fetchLimit = 1
           
           do {
               let existingDevices = try context.fetch(fetchRequest)
               
               if existingDevices.isEmpty {
                   let device = Devices(context: context)
                   device.name = name
                   device.ipAddress = ipAddress
                   device.status = status
                   device.lastUpdated = Date()
                   try await saveContextAsync()
               }else{
                   try await updateDevice(byName: name, newStatus: status)
               }
           } catch {
               throw error
           }
    }

    // MARK: - Fetch Devices

    func fetchAllDevices() async throws -> [Devices] {
        let request = NSFetchRequest<Devices>(entityName: "Devices")
        do {
            let devices = try await context.perform {
                try request.execute()
            }
            return devices
        } catch {
            throw error
        }
    }

    // MARK: - Fetch Device by IP Address

    func fetchDevice(byName name: String) async throws -> Devices? {
        let request = NSFetchRequest<Devices>(entityName: "Devices")
        request.predicate = NSPredicate(format: "name == %@", name)
        request.fetchLimit = 1
        do {
            let devices = try await context.perform {
                try request.execute()
            }
            return devices.first
        } catch {
            throw error
        }
    }

    // MARK: - Update Device

    func updateDevice(byName: String, newStatus: String) async throws {
        if let device = try await fetchDevice(byName: byName) {
            device.status = newStatus
            do {
                try await saveContextAsync()
            } catch {
                throw error
            }
        }
    }

    // MARK: - Delete Device

    func deleteDevice(device: Devices) async throws {
        context.delete(device)
        do {
            try await saveContextAsync()
        } catch {
            throw error
        }
    }

    // MARK: - Save Async Helper

    private func saveContextAsync() async throws {
        try await context.perform {
            if self.context.hasChanges {
                try self.context.save()
            }
        }
    }
}
