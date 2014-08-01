//
//  NSURL+Query.m
//  NSURL+Query
//
//  Created by Jon Crooke on 10/12/2013.
//  Copyright (c) 2013 Jonathan Crooke. All rights reserved.
//

#import "NSURL+QueryDictionary.h"

NSString *const URLReservedChars     = @"￼=,!$&'()*+;@?\r\n\"<>#\t :/";
static NSString *const kQuerySeparator  = @"&";
static NSString *const kQueryDivider    = @"=";
static NSString *const kQueryBegin      = @"?";
static NSString *const kFragmentBegin   = @"#";

@implementation NSURL (AB_URLQuery)

- (NSDictionary *)queryDictionary {
  return self.query.URLQueryDictionary;
}

- (NSURL *)URLByAppendingQueryDictionary:(NSDictionary*) queryDictionary {
  return [self URLByAppendingQueryDictionary:queryDictionary withSortedKeys:NO];
}

- (NSURL *)URLByAppendingQueryDictionary:(NSDictionary *)queryDictionary
                          withSortedKeys:(BOOL)sortedKeys {
  NSMutableArray *queries = [self.query length] > 0 ? @[self.query].mutableCopy : @[].mutableCopy;
  NSString *dictionaryQuery = [queryDictionary URLQueryStringWithSortedKeys:sortedKeys];
  if (dictionaryQuery) {
    [queries addObject:dictionaryQuery];
  }
  NSString *newQuery = [queries componentsJoinedByString:kQuerySeparator];

  if (newQuery.length) {
    NSArray *queryComponents = [self.absoluteString componentsSeparatedByString:kQueryBegin];
    if (queryComponents.count) {
      return [NSURL URLWithString:
              [NSString stringWithFormat:@"%@%@%@%@%@",
               queryComponents[0],                      // existing url
               kQueryBegin,
               newQuery,
               self.fragment ? kFragmentBegin : @"",
               self.fragment ? self.fragment : @""]];
    }
  }
  return self;
}

- (NSURL *)URLByAppendingQueryValue:(NSObject *)value forKey:(NSString *)key {
    NSString *newQuery = [@{key: value} URLQueryString];
    NSArray *fragmentComponents = [self.absoluteString componentsSeparatedByString:kFragmentBegin];
    return [NSURL URLWithString:
            [NSString stringWithFormat:@"%@%@%@%@%@",
             fragmentComponents[0],
             self.query ? (self.query.length ? kQuerySeparator : @"") : kQueryBegin,
             newQuery,
             self.fragment ? kFragmentBegin : @"",
             self.fragment ? self.fragment : @""]];
}

@end

#pragma mark -

@implementation NSString (URLQuery)

- (NSDictionary*) URLQueryDictionary {
  NSMutableDictionary *mute = @{}.mutableCopy;
  for (NSString *query in [self componentsSeparatedByString:kQuerySeparator]) {
    NSArray *components = [query componentsSeparatedByString:kQueryDivider];
    if (components.count == 0) {
      continue;
    }
    NSString *key = [components[0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    id value = nil;
    if (components.count == 1) {
      // key with no value
      value = [NSNull null];
    }
    if (components.count == 2) {
      value = [components[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      // cover case where there is a separator, but no actual value
      value = [value length] ? value : [NSNull null];
    }
    if (components.count > 2) {
      // invalid - ignore this pair. is this best, though?
      continue;
    }
    mute[key] = value ?: [NSNull null];
  }
  return mute.count ? mute.copy : nil;
}

@end

#pragma mark -

@implementation NSDictionary (URLQuery)

static inline NSString *URLEscape(NSString *string);

- (NSString *)URLQueryString {
  return [self URLQueryStringWithSortedKeys:NO];
}

- (NSString*) URLQueryStringWithSortedKeys:(BOOL)sortedKeys {
  NSMutableString *queryString = @"".mutableCopy;
  NSArray *keys = sortedKeys ? [self.allKeys sortedArrayUsingSelector:@selector(compare:)] : self.allKeys;
  for (NSString *key in keys) {
    id rawValue = self[key];
    NSString *value = nil;
    // beware of empty or null
    if (!(rawValue == [NSNull null] || ![rawValue description].length)) {
      value = URLEscape([self[key] description]);
    }
    [queryString appendFormat:@"%@%@%@%@",
     queryString.length ? kQuerySeparator : @"",    // appending?
     URLEscape(key),
     value ? kQueryDivider : @"",
     value ? value : @""];
  }
  return queryString.length ? queryString.copy : nil;
}

static inline NSString *URLEscape(NSString *string) {
    return ((__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
        NULL,
        (__bridge CFStringRef)string,
        NULL,
        (__bridge CFStringRef)URLReservedChars,
        kCFStringEncodingUTF8));
}

@end
