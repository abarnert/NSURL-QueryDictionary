//
//  NSURL+Query.h
//  NSURL+Query
//
//  Created by Jon Crooke on 10/12/2013.
//  Copyright (c) 2013 Jonathan Crooke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (AB_URLQuery)

/**
 *  @return URL's query component as keys/values
 *  Returns nil for an empty query
 */
- (NSDictionary *)queryDictionary;

/**
 *  @return URL with keys values appending to query string
 *  @param queryDictionary Query keys/values
 *  @param sortedKeys Sorted the keys alphabetically?
 *  @warning If keys overlap in receiver and query dictionary,
 *  behaviour is undefined.
 */
- (NSURL *)URLByAppendingQueryDictionary:(NSDictionary*)queryDictionary
                          withSortedKeys:(BOOL)sortedKeys;

/** As above, but `sortedKeys=NO` */
- (NSURL *)URLByAppendingQueryDictionary:(NSDictionary*)queryDictionary;

/** Just a single key/value pair */
- (NSURL *)URLByAppendingQueryValue:(NSObject *)value forKey:(NSString *)key;

@end

#pragma mark -

@interface NSString (AB_URLQuery)

/**
 *  @return If the receiver is a valid URL query component, returns
 *  components as key/value pairs. If couldn't split into *any* pairs,
 *  returns nil.
 */
- (NSDictionary *)URLQueryDictionary;

@end

#pragma mark -

@interface NSDictionary (AB_URLQuery)

/**
 *  @return URL query string component created from the keys and values in
 *  the dictionary. Returns nil for an empty dictionary.
 *  @param sortedKeys Sorted the keys alphabetically?
 *  @see cavetas from the main `NSURL` category as well.
 */
- (NSString *)URLQueryStringWithSortedKeys:(BOOL)sortedKeys;

/** As above, but `sortedKeys=NO` */
- (NSString *)URLQueryString;

@end
