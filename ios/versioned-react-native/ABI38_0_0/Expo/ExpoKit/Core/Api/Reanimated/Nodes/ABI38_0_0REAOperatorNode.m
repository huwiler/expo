#include <tgmath.h>

#import "ABI38_0_0REAOperatorNode.h"
#import "ABI38_0_0REANodesManager.h"

typedef id (^ABI38_0_0REAOperatorBlock)(NSArray<ABI38_0_0REANode *> *inputNodes);

#define ABI38_0_0REA_REDUCE(OP) ^(NSArray<ABI38_0_0REANode *> *inputNodes) { \
CGFloat acc = [[inputNodes[0] value] doubleValue]; \
for (NSUInteger i = 1; i < inputNodes.count; i++) { \
  CGFloat a = acc, b = [[inputNodes[i] value] doubleValue]; \
  acc = OP; \
} \
return @(acc); \
}

#define ABI38_0_0REA_SINGLE(OP) ^(NSArray<ABI38_0_0REANode *> *inputNodes) { \
CGFloat a = [[inputNodes[0] value] doubleValue]; \
return @(OP); \
}

#define ABI38_0_0REA_INFIX(OP) ^(NSArray<ABI38_0_0REANode *> *inputNodes) { \
CGFloat a = [[inputNodes[0] value] doubleValue]; \
CGFloat b = [[inputNodes[1] value] doubleValue]; \
return @(OP); \
}

@implementation ABI38_0_0REAOperatorNode {
  NSArray<NSNumber *> *_input;
  NSMutableArray<ABI38_0_0REANode *> *_inputNodes;
  ABI38_0_0REAOperatorBlock _op;
}

- (instancetype)initWithID:(ABI38_0_0REANodeID)nodeID config:(NSDictionary<NSString *,id> *)config
{
  static NSDictionary *OPS;
  static dispatch_once_t opsToken;
  dispatch_once(&opsToken, ^{
    OPS = @{
            // arithmetic
            @"add": ABI38_0_0REA_REDUCE(a + b),
            @"sub": ABI38_0_0REA_REDUCE(a - b),
            @"multiply": ABI38_0_0REA_REDUCE(a * b),
            @"divide": ABI38_0_0REA_REDUCE(a / b),
            @"pow": ABI38_0_0REA_REDUCE(pow(a, b)),
            @"modulo": ABI38_0_0REA_REDUCE(fmodf(fmodf(a, b) + b, b)),
            @"sqrt": ABI38_0_0REA_SINGLE(sqrt(a)),
            @"log": ABI38_0_0REA_SINGLE(log(a)),
            @"sin": ABI38_0_0REA_SINGLE(sin(a)),
            @"cos": ABI38_0_0REA_SINGLE(cos(a)),
            @"tan": ABI38_0_0REA_SINGLE(tan(a)),
            @"acos": ABI38_0_0REA_SINGLE(acos(a)),
            @"asin": ABI38_0_0REA_SINGLE(asin(a)),
            @"atan": ABI38_0_0REA_SINGLE(atan(a)),
            @"exp": ABI38_0_0REA_SINGLE(exp(a)),
            @"round": ABI38_0_0REA_SINGLE(round(a)),

            // logical
            @"and": ^(NSArray<ABI38_0_0REANode *> *inputNodes) {
              BOOL res = [[inputNodes[0] value] doubleValue];
              for (NSUInteger i = 1; i < inputNodes.count && res; i++) {
                res = res && [[inputNodes[i] value] doubleValue];
              }
              return res ? @(1.) : @(0.);
            },
            @"or": ^(NSArray<ABI38_0_0REANode *> *inputNodes) {
              BOOL res = [[inputNodes[0] value] doubleValue];
              for (NSUInteger i = 1; i < inputNodes.count && !res; i++) {
                res = res || [[inputNodes[i] value] doubleValue];
              }
              return res ? @(1.) : @(0.);
            },
            @"not": ABI38_0_0REA_SINGLE(!a),
            @"defined": ^(NSArray<ABI38_0_0REANode *> *inputNodes) {
              id val = [inputNodes[0] value];
              id res = @(val != nil && !([val isKindOfClass:[NSNumber class]] && isnan([val doubleValue])));
              return res;
            },

            // comparing
            @"lessThan": ABI38_0_0REA_INFIX(a < b),
            @"eq": ABI38_0_0REA_INFIX(a == b),
            @"greaterThan": ABI38_0_0REA_INFIX(a > b),
            @"lessOrEq": ABI38_0_0REA_INFIX(a <= b),
            @"greaterOrEq": ABI38_0_0REA_INFIX(a >= b),
            @"neq": ABI38_0_0REA_INFIX(a != b),
            };
  });
  if ((self = [super initWithID:nodeID config:config])) {
    _input = config[@"input"];
    _inputNodes = [NSMutableArray arrayWithCapacity:_input.count];
    _op = OPS[config[@"op"]];
    if (!_op) {
      ABI38_0_0RCTLogError(@"Operator '%@' not found", config[@"op"]);
    }
  }
  return self;
}

- (id)evaluate
{
  for (NSUInteger i = 0; i < _input.count; i++) {
    _inputNodes[i] = [self.nodesManager findNodeByID:_input[i]];
  }
  return _op(_inputNodes);
}

@end

