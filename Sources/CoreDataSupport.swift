
//  CoreDataSupport.swift
//  Wind
//
//  Created by Enno Welbers on 05.12.17.
//  Copyright © 2017 Palasthotel. All rights reserved.
//

import CoreData
import Foundation

private struct AssociatedKeys {
	static var container = "wind_container"
}

public extension NSManagedObjectContext {
	var Container: Container? {
		get {
			let myInstance = (objc_getAssociatedObject(self, &AssociatedKeys.container) as? ContainerWrapper)?.Instance
			guard myInstance != nil else {
				return Application.shared.Container
			}
			return myInstance
		}
		set {
			let wrapper = ContainerWrapper()
			wrapper.Instance = newValue
			objc_setAssociatedObject(self, &AssociatedKeys.container, wrapper, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
}

open class WindManagedObject: NSManagedObject, AutomaticDependencyHandling, AutomaticWeakDependencyHandling {
	public var dependencies: [String: [Component]] = [:]
	public var weakDependencies: [String: [WeakReference]] = [:]

	open override func awakeFromFetch() {
		super.awakeFromFetch()
		try! managedObjectContext?.Container?.resolve(for: self)
	}

	open override func awake(fromSnapshotEvents flags: NSSnapshotEventType) {
		super.awake(fromSnapshotEvents: flags)
		try! managedObjectContext?.Container?.resolve(for: self)
	}

	open override func awakeFromInsert() {
		super.awakeFromInsert()
		try! managedObjectContext?.Container?.resolve(for: self)
	}
}
