// ============= Test Cases =============
import type { Equal, Expect } from "./test-utils";

type X = Promise<string>;
type Y = Promise<{ field: number }>;
type Z = Promise<Promise<string | number>>;
type Z1 = Promise<Promise<Promise<string | boolean>>>;
type T = { then: (onfulfilled: (arg: number) => any) => any };

type cases = [
  Expect<Equal<MyAwaited<X>, string>>,
  Expect<Equal<MyAwaited<Y>, { field: number }>>,
  Expect<Equal<MyAwaited<Z>, string | number>>,
  Expect<Equal<MyAwaited<Z1>, string | boolean>>,
  Expect<Equal<MyAwaited<T>, number>>
];

// @ts-expect-error
type error = MyAwaited<number>;

// ============= Your Code Here =============

// 愚直に繰り返す（有限）
// type MyAwaited<T extends Promise<unknown>> = T extends Promise<infer P>
//   ? P extends Promise<infer U>
//     ? U extends Promise<infer V>
//       ? V
//       : U
//     : P
//   : never;

// 型で再帰する && then のケースに対応してみる
// type MyAwaited<T extends Promise<unknown>> = T extends Promise<infer P>
//   ? P extends Promise<unknown>
//     ? MyAwaited<P>
//     : P
//   : T extends { then: (onfulfilled: (arg: infer V) => any) => any }
//   ? V
//   : never;

// then も generics で表現してみる
// type PromiseThen<T> = { then: (onfulfilled: (arg: T) => any) => any };
// type PromiseLike<T> = Promise<T> | PromiseThen<T>;
// type MyAwaited<T extends PromiseLike<any>> = T extends Promise<infer P>
//   ? P extends Promise<any>
//     ? MyAwaited<P>
//     : P
//   : T extends PromiseLike<infer U>
//   ? U
//   : never;

// さらに整理
type PromiseThen<T> = { then: (onfulfilled: (arg: T) => any) => any };
type PromiseLike<T> = Promise<T> | PromiseThen<T>;
type MyAwaited<T extends PromiseLike<any>> = T extends PromiseLike<infer P>
  ? P extends PromiseLike<any>
    ? MyAwaited<P>
    : P
  : never;
