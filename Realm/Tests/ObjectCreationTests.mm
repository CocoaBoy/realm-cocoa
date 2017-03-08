////////////////////////////////////////////////////////////////////////////
//
// Copyright 2017 Realm Inc.
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

#import "RLMTestCase.h"

#pragma mark - Test Objects

@interface DogExtraObject : RLMObject
@property NSString *dogName;
@property int age;
@property NSString *breed;
@end

@implementation DogExtraObject
@end

@interface BizzaroDog : RLMObject
@property int dogName;
@property NSString *age;
@end

@implementation BizzaroDog
@end


@interface PrimaryKeyWithLinkObject : RLMObject
@property NSString *primaryKey;
@property StringObject *string;
@end

//@implementation PrimaryKeyWithLinkObject
//+ (NSString *)primaryKey {
//    return @"primaryKey";
//}
//@end

#pragma mark - Tests

@interface ObjectCreationTests : RLMTestCase
@end

@implementation ObjectCreationTests

#pragma mark - Init With Value

- (void)testInitWithInvalidThings {
    RLMAssertThrowsWithReasonMatching([[DogObject alloc] initWithValue:self.nonLiteralNil],
                                      @"Must provide a non-nil value");
    RLMAssertThrowsWithReasonMatching([[DogObject alloc] initWithValue:NSNull.null],
                                      @"Invalid value '<null>' for property 'age'");
    RLMAssertThrowsWithReasonMatching([[DogObject alloc] initWithValue:@"name"],
                                      @"Invalid value 'name' to initialize object of type 'DogObject'");
}

- (void)testInitWithArray {
    auto co = [[CompanyObject alloc] initWithValue:@[]];
    XCTAssertNil(co.name);
    XCTAssertEqual(co.employees.count, 0U);

    co = [[CompanyObject alloc] initWithValue:@[@"empty company"]];
    XCTAssertEqualObjects(co.name, @"empty company");
    XCTAssertEqual(co.employees.count, 0U);

    co = [[CompanyObject alloc] initWithValue:@[@"empty company", NSNull.null]];
    XCTAssertEqualObjects(co.name, @"empty company");
    XCTAssertEqual(co.employees.count, 0U);

    co = [[CompanyObject alloc] initWithValue:@[@"empty company", @[]]];
    XCTAssertEqualObjects(co.name, @"empty company");
    XCTAssertEqual(co.employees.count, 0U);

    co = [[CompanyObject alloc] initWithValue:@[@"one employee",
                                                @[@[@"name", @2, @YES]]]];
    XCTAssertEqualObjects(co.name, @"one employee");
    XCTAssertEqual(co.employees.count, 1U);
    EmployeeObject *eo = co.employees.firstObject;
    XCTAssertEqualObjects(eo.name, @"name");
    XCTAssertEqual(eo.age, 2);
    XCTAssertEqual(eo.hired, YES);

    co = [[CompanyObject alloc] initWithValue:@[@"one employee", @[eo]]];
    XCTAssertEqualObjects(co.name, @"one employee");
    XCTAssertEqual(co.employees.count, 1U);
    eo = co.employees.firstObject;
    XCTAssertEqualObjects(eo.name, @"name");
    XCTAssertEqual(eo.age, 2);
    XCTAssertEqual(eo.hired, YES);
}

- (void)testInitWithArrayUsesDefaultValuesForMissingFields {
    auto obj = [[NumberDefaultsObject alloc] initWithValue:@[]];
    XCTAssertEqualObjects(obj.intObj, @1);
    XCTAssertEqualObjects(obj.floatObj, @2.2f);
    XCTAssertEqualObjects(obj.doubleObj, @3.3);
    XCTAssertEqualObjects(obj.boolObj, @NO);

    obj = [[NumberDefaultsObject alloc] initWithValue:@[@10, @22.2f]];
    XCTAssertEqualObjects(obj.intObj, @10);
    XCTAssertEqualObjects(obj.floatObj, @22.2f);
    XCTAssertEqualObjects(obj.doubleObj, @3.3);
    XCTAssertEqualObjects(obj.boolObj, @NO);
}

- (void)testInitWithInvalidArray {
    RLMAssertThrowsWithReason(([[DogObject alloc] initWithValue:@[@"name", @"age"]]),
                              @"Invalid value 'age' for property 'age'");
    RLMAssertThrowsWithReason(([[DogObject alloc] initWithValue:@[@"name", NSNull.null]]),
                              @"Invalid value '<null>' for property 'age'");
    RLMAssertThrowsWithReason(([[DogObject alloc] initWithValue:@[@"name", @5, @"too many values"]]),
                              @"Invalid array input: more values (3) than properties (2).");
}

- (void)testInitWithDictionary {
    auto co = [[CompanyObject alloc] initWithValue:@{}];
    XCTAssertNil(co.name);
    XCTAssertEqual(co.employees.count, 0U);

    co = [[CompanyObject alloc] initWithValue:@{@"name": NSNull.null}];
    XCTAssertNil(co.name);
    XCTAssertEqual(co.employees.count, 0U);

    co = [[CompanyObject alloc] initWithValue:@{@"name": @"empty company"}];
    XCTAssertEqualObjects(co.name, @"empty company");
    XCTAssertEqual(co.employees.count, 0U);

    co = [[CompanyObject alloc] initWithValue:@{@"name": @"empty company",
                                                @"employees": NSNull.null}];
    XCTAssertEqualObjects(co.name, @"empty company");
    XCTAssertEqual(co.employees.count, 0U);

    co = [[CompanyObject alloc] initWithValue:@{@"name": @"empty company",
                                                @"employees": @[]}];
    XCTAssertEqualObjects(co.name, @"empty company");
    XCTAssertEqual(co.employees.count, 0U);

    co = [[CompanyObject alloc] initWithValue:@{@"name": @"one employee",
                                                @"employees": @[@[@"name", @2, @YES]]}];
    XCTAssertEqualObjects(co.name, @"one employee");
    XCTAssertEqual(co.employees.count, 1U);
    EmployeeObject *eo = co.employees.firstObject;
    XCTAssertEqualObjects(eo.name, @"name");
    XCTAssertEqual(eo.age, 2);
    XCTAssertEqual(eo.hired, YES);

    co = [[CompanyObject alloc] initWithValue:@{@"name": @"one employee",
                                                @"employees": @[@{@"name": @"name",
                                                                  @"age": @2,
                                                                  @"hired": @YES}]}];
    XCTAssertEqualObjects(co.name, @"one employee");
    XCTAssertEqual(co.employees.count, 1U);
    eo = co.employees.firstObject;
    XCTAssertEqualObjects(eo.name, @"name");
    XCTAssertEqual(eo.age, 2);
    XCTAssertEqual(eo.hired, YES);

    co = [[CompanyObject alloc] initWithValue:@{@"name": @"no employees",
                                                @"extra fields": @"are okay"}];
    XCTAssertEqualObjects(co.name, @"no employees");
    XCTAssertEqual(co.employees.count, 0U);
}

- (void)testInitWithInvalidDictionary {
    RLMAssertThrowsWithReasonMatching(([[DogObject alloc] initWithValue:@{@"name": @"a", @"age": NSNull.null}]),
                                      @"Invalid value '<null>' for property 'age'");
    RLMAssertThrowsWithReasonMatching(([[DogObject alloc] initWithValue:@{@"name": @"a", @"age": NSDate.date}]),
                                      @"Invalid value '20.*' for property 'age'");
}

- (void)testInitWithDictionaryUsesDefaultValuesForMissingFields {
    auto obj = [[NumberDefaultsObject alloc] initWithValue:@{}];
    XCTAssertEqualObjects(obj.intObj, @1);
    XCTAssertEqualObjects(obj.floatObj, @2.2f);
    XCTAssertEqualObjects(obj.doubleObj, @3.3);
    XCTAssertEqualObjects(obj.boolObj, @NO);

    obj = [[NumberDefaultsObject alloc] initWithValue:@{@"intObj": @10}];
    XCTAssertEqualObjects(obj.intObj, @10);
    XCTAssertEqualObjects(obj.floatObj, @2.2f);
    XCTAssertEqualObjects(obj.doubleObj, @3.3);
    XCTAssertEqualObjects(obj.boolObj, @NO);
}

- (void)testInitWithObject {
    auto eo = [[EmployeeObject alloc] init];
    eo.name = @"employee name";
    eo.age = 1;
    eo.hired = NO;

    auto co = [[CompanyObject alloc] init];
    co.name = @"name";
    [co.employees addObject:eo];

    auto co2 = [[CompanyObject alloc] initWithValue:co];
    XCTAssertEqualObjects(co.name, co2.name);
    XCTAssertEqual(co.employees[0], co2.employees[0]); // not EqualObjects as it's a shallow copy

    auto dogExt = [[DogExtraObject alloc] initWithValue:@[@"Fido", @12, @"Poodle"]];
    auto dog = [[DogObject alloc] initWithValue:dogExt];
    XCTAssertEqualObjects(dog.dogName, @"Fido");
    XCTAssertEqual(dog.age, 12);

    auto owner = [[OwnerObject alloc] initWithValue:@[@"Alex", dogExt]];
    XCTAssertEqualObjects(owner.dog.dogName, @"Fido");
}

- (void)testInitWithInvalidObject {
    // No overlap in properties
    auto so = [[StringObject alloc] initWithValue:@[@"str"]];
    RLMAssertThrowsWithReasonMatching([[IntObject alloc] initWithValue:so], @"missing key 'intCol'");

    // Dog has some but not all of DogExtra's properties
    auto dog = [[DogObject alloc] initWithValue:@[@"Fido", @10]];
    RLMAssertThrowsWithReasonMatching([[DogExtraObject alloc] initWithValue:dog], @"missing key 'breed'");

    // Same property names, but different types
    RLMAssertThrowsWithReasonMatching([[BizzaroDog alloc] initWithValue:dog],
                                      @"Invalid value 'Fido' for property 'dogName'");
}

- (void)testInitWithCustomAccessors {
    // Create with array
    auto ca = [[CustomAccessorsObject alloc] initWithValue:@[@"a", @1]];
    XCTAssertEqualObjects(ca.name, @"a");
    XCTAssertEqual(ca.age, 1);

    // Create with dictionary
    ca = [[CustomAccessorsObject alloc] initWithValue:@{@"name": @"b", @"age": @2}];
    XCTAssertEqualObjects(ca.name, @"b");
    XCTAssertEqual(ca.age, 2);

    // Create with KVO-compatible object
    ca = [[CustomAccessorsObject alloc] initWithValue:ca];
    XCTAssertEqualObjects(ca.name, @"b");
    XCTAssertEqual(ca.age, 2);
}

- (void)testInitAllPropertyTypes {
    auto now = [NSDate date];
    auto bytes = [NSData dataWithBytes:"a" length:1];
    auto so = [[StringObject alloc] init];
    so.stringCol = @"string";
    auto ao = [[AllTypesObject alloc] initWithValue:@[@YES, @1, @1.1f, @1.11,
                                                      @"string", bytes,
                                                      now, @YES, @11, so]];
    XCTAssertEqual(ao.boolCol, YES);
    XCTAssertEqual(ao.intCol, 1);
    XCTAssertEqual(ao.floatCol, 1.1f);
    XCTAssertEqual(ao.doubleCol, 1.11);
    XCTAssertEqualObjects(ao.stringCol, @"string");
    XCTAssertEqualObjects(ao.binaryCol, bytes);
    XCTAssertEqual(ao.dateCol, now);
    XCTAssertEqual(ao.cBoolCol, true);
    XCTAssertEqual(ao.longCol, 11);
    XCTAssertEqual(ao.objectCol, so);

    auto opt = [[AllOptionalTypes alloc] initWithValue:@[NSNull.null, NSNull.null,
                                                         NSNull.null, NSNull.null,
                                                         NSNull.null, NSNull.null,
                                                         NSNull.null]];
    XCTAssertNil(opt.intObj);
    XCTAssertNil(opt.boolObj);
    XCTAssertNil(opt.floatObj);
    XCTAssertNil(opt.doubleObj);
    XCTAssertNil(opt.date);
    XCTAssertNil(opt.data);
    XCTAssertNil(opt.string);

    opt = [[AllOptionalTypes alloc] initWithValue:@[@1, @2.2f, @3.3, @YES,
                                                    @"str", bytes, now]];
    XCTAssertEqualObjects(opt.intObj, @1);
    XCTAssertEqualObjects(opt.boolObj, @YES);
    XCTAssertEqualObjects(opt.floatObj, @2.2f);
    XCTAssertEqualObjects(opt.doubleObj, @3.3);
    XCTAssertEqualObjects(opt.date, now);
    XCTAssertEqualObjects(opt.data, bytes);
    XCTAssertEqualObjects(opt.string, @"str");
}

#pragma mark - Create

- (void)testCreateWithArray {
    auto realm = RLMRealm.defaultRealm;
    [realm beginWriteTransaction];

    auto co = [CompanyObject createInRealm:realm withValue:@[@"empty company", NSNull.null]];
    XCTAssertEqualObjects(co.name, @"empty company");
    XCTAssertEqual(co.employees.count, 0U);

    co = [CompanyObject createInRealm:realm withValue:@[@"empty company", @[]]];
    XCTAssertEqualObjects(co.name, @"empty company");
    XCTAssertEqual(co.employees.count, 0U);

    co = [CompanyObject createInRealm:realm withValue:@[@"one employee",
                                                        @[@[@"name", @2, @YES]]]];
    XCTAssertEqualObjects(co.name, @"one employee");
    XCTAssertEqual(co.employees.count, 1U);
    EmployeeObject *eo = co.employees.firstObject;
    XCTAssertEqualObjects(eo.name, @"name");
    XCTAssertEqual(eo.age, 2);
    XCTAssertEqual(eo.hired, YES);

    [realm cancelWriteTransaction];
}

- (void)testCreateWithInvalidArray {
    auto realm = RLMRealm.defaultRealm;
    [realm beginWriteTransaction];

    RLMAssertThrowsWithReasonMatching(([DogObject createInRealm:realm withValue:@[@"name", @"age"]]),
                                      @"Invalid value 'age' for property 'age'");
    RLMAssertThrowsWithReasonMatching(([DogObject createInRealm:realm withValue:@[@"name", NSNull.null]]),
                                      @"Invalid value '<null>' for property 'age'");
    RLMAssertThrowsWithReasonMatching(([DogObject createInRealm:realm withValue:@[@"name", @5, @"too many values"]]),
                                      @"Invalid array input: more values \\(3\\) than properties \\(2\\).");
    RLMAssertThrowsWithReasonMatching(([PrimaryStringObject createInRealm:realm withValue:@[]]),
                                      @"Invalid array input: primary key must be present.");

    [realm cancelWriteTransaction];
}

- (void)testCreateWithDictionary {
    auto realm = RLMRealm.defaultRealm;
    [realm beginWriteTransaction];

    auto co = [CompanyObject createInRealm:realm withValue:@{}];
    XCTAssertNil(co.name);
    XCTAssertEqual(co.employees.count, 0U);

    co = [CompanyObject createInRealm:realm withValue:@{@"name": NSNull.null}];
    XCTAssertNil(co.name);
    XCTAssertEqual(co.employees.count, 0U);

    co = [CompanyObject createInRealm:realm withValue:@{@"name": @"empty company"}];
    XCTAssertEqualObjects(co.name, @"empty company");
    XCTAssertEqual(co.employees.count, 0U);

    co = [CompanyObject createInRealm:realm withValue:@{@"name": @"empty company",
                                                        @"employees": NSNull.null}];
    XCTAssertEqualObjects(co.name, @"empty company");
    XCTAssertEqual(co.employees.count, 0U);

    co = [CompanyObject createInRealm:realm withValue:@{@"name": @"empty company",
                                                        @"employees": @[]}];
    XCTAssertEqualObjects(co.name, @"empty company");
    XCTAssertEqual(co.employees.count, 0U);

    co = [CompanyObject createInRealm:realm withValue:@{@"name": @"one employee",
                                                        @"employees": @[@[@"name", @2, @YES]]}];
    XCTAssertEqualObjects(co.name, @"one employee");
    XCTAssertEqual(co.employees.count, 1U);
    EmployeeObject *eo = co.employees.firstObject;
    XCTAssertEqualObjects(eo.name, @"name");
    XCTAssertEqual(eo.age, 2);
    XCTAssertEqual(eo.hired, YES);

    co = [CompanyObject createInRealm:realm withValue:@{@"name": @"one employee",
                                                        @"employees": @[@{@"name": @"name",
                                                                          @"age": @2,
                                                                          @"hired": @YES}]}];
    XCTAssertEqualObjects(co.name, @"one employee");
    XCTAssertEqual(co.employees.count, 1U);
    eo = co.employees.firstObject;
    XCTAssertEqualObjects(eo.name, @"name");
    XCTAssertEqual(eo.age, 2);
    XCTAssertEqual(eo.hired, YES);

    co = [CompanyObject createInRealm:realm withValue:@{@"name": @"no employees",
                                                        @"extra fields": @"are okay"}];
    XCTAssertEqualObjects(co.name, @"no employees");
    XCTAssertEqual(co.employees.count, 0U);
}

- (void)testCreateWithInvalidDictionary {
    auto realm = RLMRealm.defaultRealm;
    [realm beginWriteTransaction];

    RLMAssertThrowsWithReasonMatching(([DogObject createInRealm:realm withValue:@{@"name": @"a", @"age": NSNull.null}]),
                                      @"Invalid value '<null>' for property 'age'");
    RLMAssertThrowsWithReasonMatching(([DogObject createInRealm:realm withValue:@{@"name": @"a", @"age": NSDate.date}]),
                                      @"Invalid value '20.*' for property 'age'");
}

- (void)testCreateWithObject {
    auto realm = RLMRealm.defaultRealm;
    [realm beginWriteTransaction];

    auto eo = [[EmployeeObject alloc] init];
    eo.name = @"employee name";
    eo.age = 1;
    eo.hired = NO;

    auto co = [[CompanyObject alloc] init];
    co.name = @"name";
    [co.employees addObject:eo];

    auto co2 = [CompanyObject createInRealm:realm withValue:co];
    XCTAssertEqualObjects(co.name, co2.name);
    // Deep copy, so it's a different object
    XCTAssertFalse([co.employees[0] isEqualToObject:co2.employees[0]]);
    XCTAssertEqualObjects(co.employees[0].name, co2.employees[0].name);

    auto dogExt = [DogExtraObject createInRealm:realm withValue:@[@"Fido", @12, @"Poodle"]];
    auto dog = [DogObject createInRealm:realm withValue:dogExt];
    XCTAssertEqualObjects(dog.dogName, @"Fido");
    XCTAssertEqual(dog.age, 12);

    auto owner = [OwnerObject createInRealm:realm withValue:@[@"Alex", dogExt]];
    XCTAssertEqualObjects(owner.dog.dogName, @"Fido");
}

- (void)testCreateWithInvalidObject {
    auto realm = RLMRealm.defaultRealm;
    [realm beginWriteTransaction];

    RLMAssertThrowsWithReasonMatching([DogObject createInRealm:realm withValue:self.nonLiteralNil],
                                      @"Must provide a non-nil value");
    RLMAssertThrowsWithReasonMatching([DogObject createInRealm:realm withValue:@""],
                                      @"Invalid value '' to initialize object of type 'DogObject'");

    // No overlap in properties
    auto so = [StringObject createInRealm:realm withValue:@[@"str"]];
    RLMAssertThrowsWithReasonMatching([IntObject createInRealm:realm withValue:so], @"missing key 'intCol'");

    // Dog has some but not all of DogExtra's properties
    auto dog = [DogObject createInRealm:realm withValue:@[@"Fido", @10]];
    RLMAssertThrowsWithReasonMatching([DogExtraObject createInRealm:realm withValue:dog],
                                      @"missing key 'breed'");

    // Same property names, but different types
    RLMAssertThrowsWithReasonMatching([BizzaroDog createInRealm:realm withValue:dog],
                                      @"Invalid value 'Fido' for property 'dogName'");
}

- (void)testCreateAllPropertyTypes {
    auto realm = RLMRealm.defaultRealm;
    [realm beginWriteTransaction];

    auto now = [NSDate date];
    auto bytes = [NSData dataWithBytes:"a" length:1];
    auto so = [[StringObject alloc] init];
    so.stringCol = @"string";
    auto ao = [AllTypesObject createInRealm:realm withValue:@[@YES, @1, @1.1f, @1.11,
                                                              @"string", bytes,
                                                              now, @YES, @11, so]];
    XCTAssertEqual(ao.boolCol, YES);
    XCTAssertEqual(ao.intCol, 1);
    XCTAssertEqual(ao.floatCol, 1.1f);
    XCTAssertEqual(ao.doubleCol, 1.11);
    XCTAssertEqualObjects(ao.stringCol, @"string");
    XCTAssertEqualObjects(ao.binaryCol, bytes);
    XCTAssertEqualObjects(ao.dateCol, now);
    XCTAssertEqual(ao.cBoolCol, true);
    XCTAssertEqual(ao.longCol, 11);
    XCTAssertNotEqual(ao.objectCol, so);
    XCTAssertEqualObjects(ao.objectCol.stringCol, @"string");

    auto opt = [AllOptionalTypes createInRealm:realm withValue:@[NSNull.null, NSNull.null,
                                                                 NSNull.null, NSNull.null,
                                                                 NSNull.null, NSNull.null,
                                                                 NSNull.null]];
    XCTAssertNil(opt.intObj);
    XCTAssertNil(opt.boolObj);
    XCTAssertNil(opt.floatObj);
    XCTAssertNil(opt.doubleObj);
    XCTAssertNil(opt.date);
    XCTAssertNil(opt.data);
    XCTAssertNil(opt.string);

    opt = [AllOptionalTypes createInRealm:realm withValue:@[@1, @2.2f, @3.3, @YES,
                                                            @"str", bytes, now]];
    XCTAssertEqualObjects(opt.intObj, @1);
    XCTAssertEqualObjects(opt.boolObj, @YES);
    XCTAssertEqualObjects(opt.floatObj, @2.2f);
    XCTAssertEqualObjects(opt.doubleObj, @3.3);
    XCTAssertEqualObjects(opt.date, now);
    XCTAssertEqualObjects(opt.data, bytes);
    XCTAssertEqualObjects(opt.string, @"str");
}

- (void)testCreateUsesDefaultValuesForMissingDictionaryKeys {

}

- (void)testCreateOnManagedObjectInSameRealm {

}

- (void)testCreateOnManagedObjectInDifferentRealm {

}

- (void)testCreateWithInvalidatedObject {
    auto realm = [RLMRealm defaultRealm];

    [realm beginWriteTransaction];
    auto obj1 = [IntObject createInRealm:realm withValue:@[@0]];
    auto obj2 = [IntObject createInRealm:realm withValue:@[@1]];
    auto obj1alias = [IntObject allObjectsInRealm:realm].firstObject;

    [realm deleteObject:obj1];
    RLMAssertThrowsWithReasonMatching([IntObject createInRealm:realm withValue:obj1],
                                      @"Object has been deleted or invalidated.");
    RLMAssertThrowsWithReasonMatching([IntObject createInRealm:realm withValue:obj1alias],
                                      @"Object has been deleted or invalidated.");

    [realm commitWriteTransaction];
    [realm invalidate];
    [realm beginWriteTransaction];
    RLMAssertThrowsWithReasonMatching([IntObject createInRealm:realm withValue:obj2],
                                      @"Object has been deleted or invalidated.");
    [realm cancelWriteTransaction];
}

- (void)testCreateOutsideWriteTransaction {
    auto realm = [RLMRealm defaultRealm];
    RLMAssertThrowsWithReasonMatching([IntObject createInRealm:realm withValue:@[@0]],
                                      @"call beginWriteTransaction");
}

- (void)testCreateInNilRealm {
    RLMAssertThrowsWithReasonMatching(([IntObject createInRealm:self.nonLiteralNil withValue:@[@0]]),
                                      @"Realm must not be nil");
}

- (void)testCreatingObjectWithoutAnyPropertiesThrows {
    auto realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    RLMAssertThrows([AbstractObject createInRealm:realm withValue:@[]]);
    [realm cancelWriteTransaction];
}

- (void)testCreateWithCustomAccessors {
    auto realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];

    // Create with array
    auto ca = [CustomAccessorsObject createInRealm:realm withValue:@[@"a", @1]];
    XCTAssertEqualObjects(ca.name, @"a");
    XCTAssertEqual(ca.age, 1);

    // Create with dictionary
    ca = [CustomAccessorsObject createInRealm:realm withValue:@{@"name": @"b", @"age": @2}];
    XCTAssertEqualObjects(ca.name, @"b");
    XCTAssertEqual(ca.age, 2);

    // FIXME: doesn't work
    // Create with KVO-compatible object
//    auto ca2 = [CustomAccessorsObject createInRealm:realm withValue:ca];
//    XCTAssertEqualObjects(ca2.name, @"b");
//    XCTAssertEqual(ca2.age, 2);

    [realm cancelWriteTransaction];
}

#pragma mark - Create Or Update

- (void)testCreateOrUpdateWithoutPKThrows {
    auto realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    RLMAssertThrowsWithReason([DogObject createOrUpdateInRealm:realm withValue:@[]],
                              @"'DogObject' does not have a primary key");
    [realm cancelWriteTransaction];
}

- (void)testCreateOrUpdateUpdatesExistingItemWithSamePK {
    auto realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];

    auto so = [PrimaryStringObject createOrUpdateInRealm:realm withValue:@[@"pk", @2]];
    XCTAssertEqual(1U, [PrimaryStringObject allObjectsInRealm:realm].count);
    XCTAssertEqual(so.intCol, 2);

    auto so2 = [PrimaryStringObject createOrUpdateInRealm:realm withValue:@[@"pk", @3]];
    XCTAssertEqual(1U, [PrimaryStringObject allObjectsInRealm:realm].count);
    XCTAssertEqual(so.intCol, 3);
    XCTAssertEqualObjects(so, so2);

    [realm cancelWriteTransaction];
}

- (void)testCreateOrUpdateWithNullPrimaryKey {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];

    [PrimaryNullableStringObject createOrUpdateInRealm:realm withValue:@{@"intCol": @5}];
    [PrimaryNullableStringObject createOrUpdateInRealm:realm withValue:@{@"intCol": @7}];
    XCTAssertEqual([PrimaryNullableStringObject objectInRealm:realm forPrimaryKey:NSNull.null].intCol, 7);
    [PrimaryNullableStringObject createOrUpdateInRealm:realm withValue:@{@"stringCol": NSNull.null, @"intCol": @11}];
    XCTAssertEqual([PrimaryNullableStringObject objectInRealm:realm forPrimaryKey:nil].intCol, 11);

    [PrimaryNullableIntObject createOrUpdateInRealm:realm withValue:@{@"value": @5}];
    [PrimaryNullableIntObject createOrUpdateInRealm:realm withValue:@{@"value": @7}];
    XCTAssertEqual([PrimaryNullableIntObject objectInRealm:realm forPrimaryKey:NSNull.null].value, 7);
    [PrimaryNullableIntObject createOrUpdateInRealm:realm withValue:@{@"optIntCol": NSNull.null, @"value": @11}];
    XCTAssertEqual([PrimaryNullableIntObject objectInRealm:realm forPrimaryKey:nil].value, 11);

    [realm cancelWriteTransaction];
}

- (void)testCreateOrUpdateDoesNotModifyKeysNotPresent {
    auto realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];

    auto so = [PrimaryStringObject createOrUpdateInRealm:realm withValue:@[@"pk", @2]];
    auto so2 = [PrimaryStringObject createOrUpdateInRealm:realm withValue:@{@"stringCol": @"pk"}];
    XCTAssertEqual(1U, [PrimaryStringObject allObjectsInRealm:realm].count);
    XCTAssertEqual(so.intCol, 2);
    XCTAssertEqual(so2.intCol, 2);

    [realm cancelWriteTransaction];
}

- (void)testCreateOrUpdateDoesNotReplaceExistingValuesWithDefaults {
}

- (void)testCreateOrUpdateReplacesExistingArrayPropertiesAndDoesNotMergeThem {

}

- (void)testCreateOrUpdateReusesExistingLinkedObjectsWithPrimaryKeys {

}

- (void)testCreateOrUpdateCreatesNewLinkedObjectsWithoutPrimaryKeys {

}

- (void)testCreateOrUpdateWithMissingValuesAndNoExistingObject {
    auto realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    RLMAssertThrowsWithReason([PrimaryStringObject createOrUpdateInRealm:realm withValue:@{@"stringCol": @"pk"}],
                              @"Property 'intCol' of object of type 'PrimaryStringObject' cannot be nil.");
    [realm cancelWriteTransaction];
}

- (void)testCreateOrUpdateOnManagedObjectInSameRealmIsNoOp {

}

- (void)testCreateOrUpdateOnManagedObjectInDifferentRealmCopies {

}

#pragma mark - Add

- (void)testAddInvalidated {
    auto realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];

    auto dog = [DogObject createInRealm:realm withValue:@[@"name", @1]];
    [realm deleteObject:dog];
    RLMAssertThrowsWithReason([realm addObject:dog],
                              @"Adding a deleted or invalidated");
}

- (void)testAddDuplicatePrimaryKey {
#if 0
    auto realm = [RLMRealm defaultRealm];

    auto so1 = [PrimaryStringObject]
    [realm beginWriteTransaction];

    auto dog = [DogObject createInRealm:realm withValue:@[@"name", @1]];
    [realm deleteObject:dog];
    RLMAssertThrowsWithReason([realm addObject:dog], @"asdf");
#endif
}

- (void)testAddNested {
    auto realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];

    auto co = [[CompanyObject alloc] initWithValue:@[@"one employee",
                                                     @[@[@"name", @2, @YES]]]];
    [realm addObject:co];
    XCTAssertEqual(co.realm, realm);
    XCTAssertEqualObjects(co.name, @"one employee");

    auto eo = co.employees[0];
    XCTAssertEqual(eo.realm, realm);
    XCTAssertEqualObjects(eo.name, @"name");

    eo = [[EmployeeObject alloc] initWithValue:@[@"name 2", @3, @NO]];
    co = [[CompanyObject alloc] initWithValue:@[@"one employee", @[eo]]];

    [realm addObject:co];
    XCTAssertEqual(co.realm, realm);
    XCTAssertEqual(eo.realm, realm);

    [realm cancelWriteTransaction];
}

- (void)testAddingObjectWithoutAnyPropertiesThrows {
    auto realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    RLMAssertThrows([realm addObject:[[AbstractObject alloc] initWithValue:@[]]]);
    [realm cancelWriteTransaction];
}

- (void)testAddWithCustomAccessors {
    auto realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];

    auto ca = [[CustomAccessorsObject alloc] initWithValue:@[@"a", @1]];
    [realm addObject:ca];
    XCTAssertEqualObjects(ca.name, @"a");
    XCTAssertEqual(ca.age, 1);

    [realm cancelWriteTransaction];
}

- (void)testAddToCurrentRealmIsNoOp {
    DogObject *dog = [[DogObject alloc] init];

    auto realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];

    [realm addObject:dog];
    XCTAssertEqual(dog.realm, realm);
    XCTAssertEqual(1U, [DogObject allObjectsInRealm:realm].count);

    XCTAssertNoThrow([realm addObject:dog]);
    XCTAssertEqual(dog.realm, realm);
    XCTAssertEqual(1U, [DogObject allObjectsInRealm:realm].count);

    [realm cancelWriteTransaction];
}

- (void)testAddToDifferentRealmThrows {
    auto eo = [[EmployeeObject alloc] init];

    auto realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addObject:eo];

    auto realm2 = [self realmWithTestPath];
    [realm2 beginWriteTransaction];

    RLMAssertThrowsWithReason([realm2 addObject:eo],
                              @"Object is already managed by another Realm. Use create instead to copy it into this Realm.");
    XCTAssertEqual(eo.realm, realm);

    auto co = [CompanyObject new];
    [co.employees addObject:eo];
    RLMAssertThrowsWithReason([realm2 addObject:co],
                              @"Can not add objects from a different Realm");
    XCTAssertEqual(co.realm, realm2);

    [realm cancelWriteTransaction];
    [realm2 cancelWriteTransaction];
}

- (void)testAddToCurrentRealmChecksForWrite {
    DogObject *dog = [[DogObject alloc] init];

    auto realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addObject:dog];
    [realm commitWriteTransaction];

    RLMAssertThrowsWithReason([realm addObject:dog],
                              @"call beginWriteTransaction");
}

#pragma mark - Add Or Update

- (void)testAddOrUpdateWithoutPKThrows {
    auto realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];

    RLMAssertThrowsWithReason([realm addOrUpdateObject:[DogObject new]],
                              @"'DogObject' does not have a primary key");
}









- (void)testCreateOrUpdateSameRealm {
    RLMRealm *realm = self.realmWithTestPath;
    [realm beginWriteTransaction];
    PrimaryKeyWithLinkObject *object = [PrimaryKeyWithLinkObject createInRealm:realm withValue:@[@"", @[@""]]];
    PrimaryKeyWithLinkObject *returnedObject = [PrimaryKeyWithLinkObject createOrUpdateInRealm:realm withValue:object];
    XCTAssertEqual(object, returnedObject);
    [realm commitWriteTransaction];
}

- (void)testClassExtension {
    RLMRealm *realm = [RLMRealm defaultRealm];

    [realm beginWriteTransaction];
    BaseClassStringObject *bObject = [[BaseClassStringObject alloc ] init];
    bObject.intCol = 1;
    bObject.stringCol = @"stringVal";
    [realm addObject:bObject];
    [realm commitWriteTransaction];

    BaseClassStringObject *objectFromRealm = [BaseClassStringObject allObjects][0];
    XCTAssertEqual(1, objectFromRealm.intCol, @"Should be 1");
    XCTAssertEqualObjects(@"stringVal", objectFromRealm.stringCol, @"Should be stringVal");
}

@end
