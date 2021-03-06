//
//  ExternalTest1.swift
//  EonilSQLite3
//
//  Created by Hoon H. on 9/20/14.
//
//

import Foundation
import EonilSQLite3

func test2()
{
	func basics()
	{
		
		///	Create new mutable database in memory.
		let	db1	=	Database(location: Database.Location.Memory, mutable: true)
		
		///	Create a new table.
		db1.schema().create(table: "T1", column: ["c1"])
		
		///	Make a single table accessor object.
		let	t1	=	db1.table(name: "T1")
		
		///	Insert a new row.
		t1.insert(rowWith: ["c1":"V1"])
		
		///	Verify by selecting all current rows.
		let	rs1	=	t1.select()
		assert(rs1.count == 1)
		assert(rs1[0]["c1"]! as String == "V1")
		
		///	Update the row.
		t1.update(rowsWithAllOf: ["c1":"V1"], bySetting: ["c1":"W2"])
		
		///	Verify!
		let	rs2	=	t1.select()
		assert(rs2.count == 1)
		assert(rs2[0]["c1"]! as String == "W2")
		
		///	Delete the row.
		t1.delete(rowsWithAllOf: ["c1":"W2"])
		
		///	Verify!
		let	rs3	=	t1.select()
		assert(rs3.count == 0)
	}
	
	func basicsWithTransaction()
	{
		///	Create new mutable database in memory.
		let	db1	=	Database(location: Database.Location.Memory, mutable: true)
		func tx1()
		{
			///	Create a new table.
			db1.schema().create(table: "T1", column: ["c1"])
			
			///	Make a single table accessor object.
			let	t1	=	db1.table(name: "T1")
			
			///	Insert a new row.
			t1.insert(rowWith: ["c1":"V1"])
			
			///	Verify by selecting all current rows.
			let	rs1	=	t1.select()
			assert(rs1.count == 1)
			assert(rs1[0]["c1"]! as String == "V1")
			
			///	Update the row.
			t1.update(rowsWithAllOf: ["c1":"V1"], bySetting: ["c1":"W2"])
			
			///	Verify!
			let	rs2	=	t1.select()
			assert(rs2.count == 1)
			assert(rs2[0]["c1"]! as String == "W2")
			
			///	Delete the row.
			t1.delete(rowsWithAllOf: ["c1":"W2"])
			
			///	Verify!
			let	rs3	=	t1.select()
			assert(rs3.count == 0)
		}
		
		///	Perform a transaction with multiple commands.
		db1.apply(tx1)
	}
	func nestedTransactions()
	{
		let	db1	=	Database(location: Database.Location.Memory, mutable: true)
		
		///	Out-most transaction.
		func tx1()
		{
			db1.schema().create(table: "T1", column: ["c1"])
			let	t1	=	db1.table(name: "T1")
			
			///	Outer transaction.
			func tx2() -> Bool
			{
				t1.insert(rowWith: ["c1":"V1"])
			
				///	Inner transaction.
				func tx3() -> Bool
				{
					///	Update the row.
					t1.update(rowsWithAllOf: ["c1":"V1"], bySetting: ["c1":"W2"])
					
					///	Verify the update.
					let	rs2	=	t1.select()
					assert(rs2.count == 1)
					assert(rs2[0]["c1"]! as String == "W2")
					
					///	And rollback.
					return	false
				}
				db1.applyConditionally(transaction: tx3)
				
				///	Verify inner rollback.
				let	rs2	=	t1.select()
				assert(rs2.count == 1)
				assert(rs2[0]["c1"]! as String == "V1")
				
				return	false
			}
			
			///	Verify outer rollback.
			let	rs2	=	t1.select()
			assert(rs2.count == 0)
		}
		db1.apply(tx1)
	}
	
	func customQuery()
	{
		let	db1	=	Database(location: Database.Location.Memory, mutable: true)
		db1.schema().create(table: "T1", column: ["c1"])
		
		let	t1	=	db1.table(name: "T1")
		t1.insert(rowWith: ["c1":"V1"])
		
		db1.apply {
			db1.run(query: "SELECT * FROM T1", success: { (data) -> () in
				for row in data
				{
					assert(row[0] as String == "V1")
				}
			}, failure: { (message) -> () in
				
			})
		}
	}
	
	basics()
	basicsWithTransaction()
	nestedTransactions()
	customQuery()
}

