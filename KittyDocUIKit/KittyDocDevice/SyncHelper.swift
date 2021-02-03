//
//  SyncHelper.swift
//  KittyDocBLETest
//
//  Created by 곽명섭 on 2021/01/20.
//

import Foundation
import CoreData

class SyncHelper: NSObject {
    public static let shared = SyncHelper()//+ (SyncHelper *)sharedInstance;
    
//    private override init() {
//
//    }
    func parseData(data: Data) {
//        var cdm: CoreDataManager = CoreDataManager.sharedManager()
        
        var e: Dictionary<String, Any> = Dictionary<String, Any>()
        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "s_tick", ascending: true)
        var sortDescriptors: NSArray = [sortDescriptor]
        let version: String = DeviceManager.shared.firmwareVersion
        var kittydoc_data: KittyDoc_Ext_Interface_Data_Type// 10분단위가 6개 모이고 위에 타임존, 리셋회수, 남은 개수 데이터가 있는 데이터
//        var bytes: [UInt8] = [UInt8](data)//.bytes)

        //for( int i=0; i<data.length && i+sizeof(sleepdoc_data) <= data.length ; i+=sizeof(sleepdoc_data) )
        for i in stride(from: 0, to: data.count, by: 154) where (i < data.count && i+154 <= data.count) {
            let temp: Data = data.subdata(in: 0..<154)
            kittydoc_data = KittyDoc_Ext_Interface_Data_Type(data: temp)
            
            for j in 0..<6 {
                let d = kittydoc_data.d[j]
                
                // tick이 0인놈 있으면 무시
                if (d.s_tick == 0 || d.e_tick == 0) {
                    continue
                }
                
                let s_time: String = unixtimeToString(unixtime: time_t(d.s_tick))
                let e_time: String = unixtimeToString(unixtime: time_t(d.e_tick))
                
                //print("\(i):s_tick=\(d.s_tick) \(s_time) e_tick=\(d.e_tick) \(e_time) steps=\(d.steps) t_lux=\(d.t_lux) avg_lux=\(d.avg_lux) avg_k=\(d.avg_k)")
                print("\t\(d.s_tick)\t\(s_time)\t\(d.e_tick)\t\(e_time)\t\(d.steps)\t\(d.t_lux)\t\(d.avg_lux)\t\(d.avg_k)\t\(d.vector_x)\t\(d.vector_y)\t\(d.vector_z)")

//                // DB에 있는 해당 시간동안의 기존 데이터 삭제??
//                var predivate: NSPredicate = NSPredicate(format: "(s_tick >= %ld) AND (e_tick <= %ld)", d.s_tick, d.e_tick)
//                var rc: NSFetchedResultsController = cdm.fetchEntitiesWithClassName("SyncData", sortDescriptors: sortDescriptors, sectionNameKeyPath: nil, predicate:predicate) // NSFetchedResultsController *rc = [cdm fetchEntitiesWithClassName:@"SyncData"
//
//                print(" deleting count : \(rc.fetchedObjects.count)")
//                for i in 0..<rc.fetchedObjects.count {
//                    // get one
//                    //var object: NSManagedObject = NSManagedObject(rc.fetchedObjects.objectAtIndex(i))// NSManagedObject *object = [rc.fetchedObjects objectAtIndex:i];
//                    //cdm.managedObjectContext.deleteObject(object)//[cdm.managedObjectContext deleteObject:object];
//                }
                
                // Insert to DB
                e["s_tick"]     = NSNumber(value: d.s_tick)//[NSNumber numberWithUnsignedLong:d.s_tick];
                e["e_tick"]     = NSNumber(value: d.e_tick)//[NSNumber numberWithUnsignedLong:d.e_tick];
                e["steps"]      = NSNumber(value: d.steps)//[NSNumber numberWithInt:d.steps];
                e["t_lux"]      = NSNumber(value: d.t_lux)//[NSNumber numberWithUnsignedLong:d.t_lux];
                e["avg_lux"]    = NSNumber(value: d.avg_lux)//[NSNumber numberWithInt:d.avg_lux];
                e["avg_k"]      = NSNumber(value: d.avg_k)//[NSNumber numberWithInt:d.avg_k];
                e["vector_x"]   = NSNumber(value: d.vector_x)//[NSNumber numberWithInt:d.vector.x];
                e["vector_y"]   = NSNumber(value: d.vector_y)//[NSNumber numberWithInt:d.vector.y];
                e["vector_z"]   = NSNumber(value: d.vector_z)//[NSNumber numberWithInt:d.vector.z];
                e["timezone"]   = NSNumber(value: d.vector_y)//[NSNumber numberWithInt:sleepdoc_data.time_zone];
                e["version"]    = version
                
                // Discard All data with unixtime 0
                if (d.s_tick > 0 && d.e_tick > 0) {
//                    cdm.createEntityWithClassName("SyncData").attributesDictionary(e)//[cdm createEntityWithClassName:@"SyncData" attributesDictionary:e];
                } else {
                    print("  DISCARDED 0 UNIXTIME DATA !!!");
                }
            }
            print("timezone offset:\(kittydoc_data.time_zone)")
        }
        
//        var error: NSError = NSError()
//        cdm.managedObjectContext.save(error)//[[cdm managedObjectContext] save:&error];
    }
    
    // unixtime 값을 문자열로 변환하여 반환
    func unixtimeToString(unixtime: time_t) -> String { // SleepDoc_Ext_Interface_Data_Type.time_zone 고려 추가?
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = String("yyyy-MM-dd HH:mm:ss") //String("yyyy-MM-dd HH:mm:ss.SSS")
    //    dateFormatter.setLocalizedDateFormatFromTemplate(Locale.current.languageCode!)
    //    dateFormatter.locale = Locale.current
    //    dateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
        let current_date_string = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(unixtime)))
        //print("unixtime : \(unixtime), result : \(current_date_string)")

        return current_date_string // dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(unixtime)))
    }
    
    func createTestDB() {
//        var cdm: CoreDataManager = CoreDataManager.shared //CoreDataManager *cdm = [CoreDataManager sharedManager];
//        cdm.resetDB()//[cdm resetDB];

        // 2일치 데이터를 만든다
        var date1 = Date(timeIntervalSinceNow: -4 * 24 * 60 * 60)//[NSDate dateWithTimeIntervalSinceNow: -4 * 24 * 60 * 60];
        var date2 = Date(timeIntervalSinceNow: 0 * 24 * 60 * 60)//[NSDate dateWithTimeIntervalSinceNow: 0 * 24 * 60 * 60];
        
        repeat {
            var calendar: Calendar = Calendar.current//NSCalendar *calendar = [NSCalendar currentCalendar];
            var componentSet = Set<Calendar.Component>()
            componentSet.insert(Calendar.Component.hour)
            componentSet.insert(Calendar.Component.minute)
            let components: DateComponents = calendar.dateComponents([.hour, .minute], from: date1)
            var hour: Int = components.hour!
            var stepsFactor: Float = (hour > 0 && hour <= 6 ? 0.02 : (hour > 18 && hour < 24 ? 0.5 : 1.0))
            var luxFactor: Float = (hour > 0 && hour <= 10 ? 0.01 : (hour > 13 && hour < 24 ? 0.2 : 1.0))
            let rand = arc4random()
            var steps: Int = Int(Float(rand % 100) * stepsFactor)
            if rand % 100 >= 90 {
                steps = 22
            }
            
            var d: Dictionary<String, Any> = Dictionary<String, Any>()
            d["s_tick"]     = NSNumber(value: date1.timeIntervalSince1970)//[NSNumber numberWithUnsignedLong:[date1 timeIntervalSince1970]];
            d["e_tick"]     = NSNumber(value: date1.timeIntervalSince1970 + 60)//[NSNumber numberWithUnsignedLong:[date1 timeIntervalSince1970]+60];
            d["steps"]      = NSNumber(value: steps)//[NSNumber numberWithInt: steps];
            d["t_lux"]      = NSNumber(value: Float(rand % 20000) * luxFactor)//[NSNumber numberWithUnsignedLong: rand() % 20000 * luxFactor];
            d["avg_lux"]    = NSNumber(value: Float(rand % 3000) * luxFactor)//[NSNumber numberWithInt: rand() % 3000 * luxFactor];
            d["avg_k"]      = NSNumber(value: Float(rand % 8000) * luxFactor)//[NSNumber numberWithInt: rand() % 8000 * luxFactor];
            d["timezone"]   = NSNumber(value: -9 * 60 * 60)//[NSNumber numberWithLong:-9 * 60 * 60];
            d["version"]    = "1.0.0"
//            cdm.createEntityWithClassName("SyncData").attributesDictionary(d)//[cdm createEntityWithClassName:@"SyncData" attributesDictionary:d];
            print("Adding data of date:\(date1) \(d)")
            date1 = Date(timeInterval: 10*60, since: date1)//date1 = [date1 dateByAddingTimeInterval: 10*60];
        } while date1.compare(date2) == .orderedAscending //ComparisonResult.orderedDescending
        
//        var data: SyncData = NSEntityDescription.insertNewObject(forEntityName: "SyncData", into: cdm.managedObjectContext())//SyncData *data = [NSEntityDescription insertNewObjectForEntityForName:@"SyncData" inManagedObjectContext:[cdm managedObjectContext]];
//        data.s_tick = ""//data.s_tick = ;

//        var error: NSError = NSError()
//        cdm.managedObjectContext.save(error)//[[cdm managedObjectContext] save:&error];
    }
    
    func testWriteDB() {
        print("[+]testWriteDB")
//        var cdm: CoreDataManager = CoreDataManager.shared
//        cdm.resetDB()//[cdm resetDB];
        let date: Date = Date(timeIntervalSince1970: 0)
        var d: Dictionary<String, Any> = Dictionary<String, Any>()
        d["s_tick"]     = NSNumber(value: date.timeIntervalSince1970)//[NSNumber numberWithUnsignedLong:[[NSDate date] timeIntervalSince1970]];
        d["e_tick"]     = NSNumber(value: date.timeIntervalSince1970 + 10)//[NSNumber numberWithUnsignedLong:[[NSDate date] timeIntervalSince1970]+10];
        d["steps"]      = NSNumber(value: 999)//[NSNumber numberWithInt:999];
        d["t_lux"]      = NSNumber(value: 100000)//[NSNumber numberWithUnsignedLong:100000];
        d["avg_lux"]    = NSNumber(value: 10000)//[NSNumber numberWithInt:10000];
        d["avg_k"]      = NSNumber(value: 4000)//[NSNumber numberWithInt:4000];
        d["timezone"]   = NSNumber(value: -9 * 60 * 60)//[NSNumber numberWithInt:-9 * 60 * 60];

//            cdm.createEntityWithClassName("SyncData").attributesDictionary(d)//[cdm createEntityWithClassName:@"SyncData" attributesDictionary:d];
    //    SyncData *data = [NSEntityDescription insertNewObjectForEntityForName:@"SyncData" inManagedObjectContext:[cdm managedObjectContext]];
    //    data.s_tick = ;
        
//        var error: NSError = NSError()
//        cdm.managedObjectContext.save(error)//[[cdm managedObjectContext] save:&error];

        print("[-]testWriteDB")
    }
    
    func testReadDB() {
        print("[+]testReadDB")
        
//        var cdm: CoreDataManager = CoreDataManager.shared//CoreDataManager *cdm = [CoreDataManager sharedManager];

        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "s_tick", ascending: true)
        var sortDescriptors: NSArray = [sortDescriptor]
        
//        var rc: NSFetchedResultsController = cdm.fetchEntitiesWithClassName("SyncData", sortDescriptors: sortDescriptors, sectionNameKeyPath: nil, predicate:nil) //NSFetchedResultsController *rc = [cdm fetchEntitiesWithClassName:@"SyncData" sortDescriptors:sortDescriptors sectionNameKeyPath:nil predicate:nil];
        //re.delegate = self
        
//        print("count : \(rc.fetchedObjects.count)")
//        for i in 0..<rc.fetchedObjects.count {
//            // get one
//            var object: NSManagedObject = rc.fetchedObjects.objectAtIndex(i)
//            print("info : \(object.value(forKey: "s_tick") as! Int)") //NSLog(@"info : %ld", [[object valueForKey:@"s_tick"] integerValue]);
//        }
        
        print("[-]testReadDB")
    }
    
    /*
     * 동기화하여 DB에 저장된 raw 데이터를 가져온다
     *
     * @param fromDate 데이터를 가져오기 시작할 시간. nil이면 처음부터 가져옴.
     * @param toDate 데이터를 가져올 마지막 시간. nil이면 현재까지.
     *
     */
    func getRawSyncDataFrom(from fromDate: Date, to toDate: Date) -> NSArray {
        return self.getRawSyncDataFrom(from: fromDate, to: toDate, minVersion: "")//[self getRawSyncDataFrom:fromDate to:toDate minVersion:nil];
    }

    func getRawSyncDataFrom(from fromDate: Date, to toDate: Date, minVersion version: String) -> NSArray { // 특정 버전 이상의 동기화 데이터 가져오기
        print("[+]getRawSyncDataFrom")
        
//        var cdm: CoreDataManager = CoreDataManager.shared

        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "s_tick", ascending: true)
        var sortDescriptors: NSArray = [sortDescriptor]
        var predicate: NSPredicate? = nil//NSPredicate *predicate = nil;

        guard fromDate.timeIntervalSince1970 >= 0 else {
            print("fromDate.timeIntervalSince1970 < 0!(getRawSyncDataFrom)")
            exit(0)
        }//assert(fromDate != nil);
        
        var array: Array = Array<Any>()//NSMutableArray *array = [NSMutableArray array];
        var time1: UInt32 = UInt32(fromDate.timeIntervalSince1970)
        var time2: UInt32 = 0
        if toDate.timeIntervalSince1970 == 0 {// toDate가 1970.01.01 00:00 일 경우
            time2 = UInt32(Date().timeIntervalSince1970)
        }
        
        if version.isEmpty {
            predicate = NSPredicate(format: "(s_tick >= %ld) AND (e_tick <= %ld)", time1, time2)//[NSPredicate predicateWithFormat:@"(s_tick >= %ld) AND (e_tick <= %ld)", time1, time2];
        } else {
            predicate = NSPredicate(format: "(s_tick >= %ld) AND (e_tick <= %ld) and (version >= '%@')", time1, time2, version)//[NSPredicate predicateWithFormat:@"(s_tick >= %ld) AND (e_tick <= %ld) and (version >= '%@')", time1, time2, version];
        }
        
//        var rc: NSFetchedResultsController = cdm.fetchEntitiesWithClassName("SyncData", sortDescriptors: sortDescriptors, sectionNameKeyPath: nil, predicate:predicate)]
//        NSFetchedResultsController *rc = [cdm fetchEntitiesWithClassName:@"SyncData"
//                                                         sortDescriptors:sortDescriptors
//                                                      sectionNameKeyPath:nil
//                                                               predicate:predicate];

        print("getRawSyncData start --------------------------")
//        let count = rc.fetchedObjects.count
//        for i in 0..<rc.fetchedObjects.count; {
//            var data: SyncData = SyncData()
//            var object: NSManagedObject = rc.fetchedObjects.objectAtIndex(i)
//
//            data.s_tick = [[object valueForKey:@"s_tick"] unsignedIntValue];
//            data.e_tick = [[object valueForKey:@"e_tick"] unsignedIntValue];
//            data.steps = [[object valueForKey:@"steps"] integerValue];
//            data.t_lux = [[object valueForKey:@"t_lux"] unsignedIntValue];
//            data.avg_lux = [[object valueForKey:@"avg_lux"] integerValue];
//            data.avg_k = [[object valueForKey:@"avg_k"] integerValue];
//            data.vector_x = [[object valueForKey:@"vector_x"] integerValue];
//            data.vector_y = [[object valueForKey:@"vector_y"] integerValue];
//            data.vector_z = [[object valueForKey:@"vector_z"] integerValue];
//            data.timezone = [[object valueForKey:@"timezone"] intValue];
//            data.version = [object valueForKey:@"version"];
//            array.addObject(data) //[array addObject:data];
//
//            print("  \(data.toSrging())")// [data toString]);
//        }
        print("getRawSyncData end --------------------------")
        
        print("[-]getRawSyncDataFrom")
        return NSArray()//return array
    }

    /*
     * 동기화하여 DB에 저장된 데이터를 CHART_X_UNIT분 단위로 합산하여 불러온다 (차트용)
     *
     * @param fromDate 데이터를 가져오기 시작할 시간. nil이면 처음부터 가져옴.
     * @param toDate 데이터를 가져올 마지막 시간. nil이면 현재까지.
     *
     */
    func getSyncDataFrom(fromDate: Date, to toDate: Date, serverData: NSArray) -> NSArray {
        print("[+]getSyncDataFrom")
        
        print("getSyncDataFrom to start --------------------------")
//        var cdm: CoreDataManager = CoreDataManager.shared
        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "s_tick", ascending: true)
        var sortDescriptors: NSArray = [sortDescriptor]
        var predicate: NSPredicate? = nil//NSPredicate *predicate = nil;

        guard fromDate.timeIntervalSince1970 >= 0 else {
            print("fromDate.timeIntervalSince1970 < 0!(getRawSyncDataFrom)")
            exit(0)
        }//assert(fromDate != nil);
        
        var array: Array = Array<Any>()//NSMutableArray *array = [NSMutableArray array];
        var time1: UInt32 = UInt32(fromDate.timeIntervalSince1970)
        var time2: UInt32 = 0
        if toDate.timeIntervalSince1970 == 0 {// toDate가 1970.01.01 00:00 일 경우
            time2 = UInt32(Date().timeIntervalSince1970)
        }
        
        // CHART_X_UNIT분 단위로 데이터 가져온다 => 앞 뒤 15분씩해서 30분간 데이터를 가져오자?? (151222)
        var halfHour: UInt32 = 60 * 60 / 2//CHART_X_UNIT
        var hasData: Bool = false
        
        repeat {
            var _d: Date = Date(timeIntervalSince1970: TimeInterval(time1))
            print("time:\(_d)")//NSLog(@"time:%@", [Util getDateString:_d]);

//            var data: SyncData = SyncData()
//            data.s
//
//            data.s_tick = time1 - (halfHour / 2)
//            data.e_tick = time1 + (halfHour / 2)
//            data.timezone = TimeZone.current.secondsFromGMT()//[Util getGMTOffset];

//            if( serverData == nil )
//            {
//                predicate = [NSPredicate predicateWithFormat:@"(s_tick >= %ld) AND (s_tick < %ld)", time-halfHour/2, time+halfHour/2];
//                NSFetchedResultsController *rc = [cdm fetchEntitiesWithClassName:@"SyncData"
//                                                                 sortDescriptors:sortDescriptors
//                                                              sectionNameKeyPath:nil
//                                                                       predicate:predicate];
//                // data가 없으면 0 값으로 채운 데이터를 추가한다
//                if( rc.fetchedObjects.count == 0 )
//                {
//                    data.steps = 0;
//                    data.t_lux = 0;
//                    data.avg_lux = 0;
//                    data.avg_k = 0;
//                }
//                else
//                {
//                    hasData = YES;
//
//                    long count = rc.fetchedObjects.count;
//                    //long secs = 0; // 누적 시간(초)
//                    int avg_lux = 0, avg_k = 0; // overflow 방지
//
//                    for( int i=0; i<count; i++)
//                    {
//                        // get one
//                        NSManagedObject *object = [rc.fetchedObjects objectAtIndex:i];
//                        int s_tick = [[object valueForKey:@"s_tick"] intValue];
//                        int e_tick = [[object valueForKey:@"e_tick"] intValue];
//                        data.steps += [[object valueForKey:@"steps"] intValue];
//                        data.t_lux += [[object valueForKey:@"t_lux"] unsignedIntValue];
//                        // avg_lux는 조도값들 중 가장 큰 값으로 표시하자. 1000lux를 넘어서 충분히 빛을 쬐었음에도 불구하고 평균값으로 구해서 충분하지 않은 것처럼 보임 방지
//                        avg_lux = MAX([[object valueForKey:@"avg_lux"] intValue], avg_lux);
//                        //avg_lux += [[object valueForKey:@"avg_lux"] intValue];
//                        avg_k += [[object valueForKey:@"avg_k"] intValue];
//
//                        //secs += e_tick - s_tick;
//                    }
//                    data.avg_lux = (uint16_t)avg_lux;// (uint16_t)(avg_lux / count);
//                    data.avg_k = (uint16_t)(avg_k / count);
//                }
//
//                //        NSLog(@"getSyncDataFrom to %@", [data toString]);
//                [array addObject:data];
//            }
//            else
//            {
//                int avg_lux = 0, avg_k = 0; // overflow 방지
//                long count = [serverData count];
//
//                data.steps = 0;
//                data.t_lux = 0;
//                data.avg_lux = 0;
//                data.avg_k = 0;
//
//                int items = 0;
//
//                for( int i=0; i<count; i++ )
//                {
//                    SyncData *d = [serverData objectAtIndex:i];
//
//                    if( d.s_tick >= time-halfHour/2 && d.s_tick < time+halfHour/2 )
//                    {
//                        hasData = YES;
//
//                        data.steps += d.steps;
//                        data.t_lux += d.t_lux;
//                        // avg_lux는 조도값들 중 가장 큰 값으로 표시하자. 1000lux를 넘어서 충분히 빛을 쬐었음에도 불구하고 평균값으로 구해서 충분하지 않은 것처럼 보임 방지
//                        avg_lux = MAX(d.avg_lux, avg_lux);
//                        //avg_lux += [[object valueForKey:@"avg_lux"] intValue];
//                        avg_k += d.avg_k;
//
//
//                        // uv는 구간중 가장 높은 값을 취하자
//                        data.med = MAX(data.med, d.med);
//
//                        items++;
//                    }
//                }
//
//                if( items > 0 )
//                {
//                    data.avg_lux = (uint16_t)avg_lux;// (uint16_t)(avg_lux / count);
//                    data.avg_k = (uint16_t)(avg_k / items);
//                }
//                [array addObject:data];
//            }

            time1 += halfHour
        } while time1 < time2
//        for( uint32_t time = [fromDate timeIntervalSince1970]; time < [toDate timeIntervalSince1970]; time += halfHour)
        
//        //print("getSyncDataFrom to end --------------------------")
        
//        if( hasData )
//            return array
//        else
//            return nil
        
        print("[-]getSyncDataFrom")
        return NSArray()
    }
    
    func getUVSyncDataFrom(fromDate: Date, to toDate: Date, serverData: NSArray) -> NSArray {// UV analysis 화면용 10분 단위 데이터
        print("[+]getUVSyncDataFrom")
        
//        print("getSyncDataFrom to start --------------------------")
//
////        var cdm: CoreDataManager = CoreDataManager.shared
//        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "s_tick", ascending: true)
//        var sortDescriptors: NSArray = [sortDescriptor]
//        var predicate: NSPredicate? = nil//NSPredicate *predicate = nil;
//
//        guard fromDate.timeIntervalSince1970 >= 0 else {
//            print("fromDate.timeIntervalSince1970 < 0!(getRawSyncDataFrom)")
//            exit(0)
//        }//assert(fromDate != nil);
//
//        var array: Array = Array<Any>()//NSMutableArray *array = [NSMutableArray array];
//        var time1: UInt32 = UInt32(fromDate.timeIntervalSince1970)
//        var time2: UInt32 = 0
//        if toDate.timeIntervalSince1970 == 0 {// toDate가 1970.01.01 00:00 일 경우
//            time2 = UInt32(Date().timeIntervalSince1970)
//        }
////        if toDate == nil {
////            toDate = [NSDate date];
////        }
//
//
//        // CHART_X_UNIT분 단위로 데이터 가져온다 => 앞 뒤 15분씩해서 30분간 데이터를 가져오자 (151222)
//        let tenMin: UInt32 = 10 * 60
//        var hasData: Bool = false
//
//        repeat {
//            var _d: Date = Date(timeIntervalSince1970: time1)
//            print("time:\(_d)")//NSLog(@"time:%@", [Util getDateString:_d]);
//
//            var data: SyncData = SyncData()
//            data.s_tick = time - (tenMin / 2)
//            data.e_tick = time + (tenMin / 2)
//            data.timezone = TimeZone.current.secondsFromGMT()//[Util getGMTOffset];
//
//            var avg_lux: Int = 0
//            var avg_k: Int = 0 // Overflow 방지?
//            var count: Int = serverData.count
//
//            data.steps = 0
//            data.t_lux = 0
//            data.avg_lux = 0
//            data.avg_k = 0
//
//            var items: Int = 0
//            for i in 0..<count {
//                var d: SyncData = serverData.object(at: i)// SyncData *d = [serverData objectAtIndex:i];
//
//                if( d.s_tick >= time-tenMin/2 && d.s_tick < time+tenMin/2 )
//                {
//                    hasData = true
//
//                    // uv는 구간중 가장 높은 값을 취하자
//                    data.med = MAX(data.med, d.med)
//
//                    items += 1
//                }
//            }
//
//            if( items > 0 )
//            {
//                data.avg_lux = UInt16(avg_lux)// UInt16(avg_lux / count)
//                data.avg_k = UInt16(avg_k / items)
//            }
//            array.append(data)//[array addObject:data];
//
//            time1 += tenMin
//        } while time1 < time2}
//
//        print("getSyncDataFrom to end --------------------------");
////        if( hasData )
////            return array;
////        else
////            return nil;

        print("[-]getUVSyncDataFrom")
        return NSArray()
    }
}
