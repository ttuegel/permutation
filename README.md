permutation
===========

[![Build Status](https://travis-ci.org/spacekitteh/permutation.svg)](https://travis-ci.org/spacekitteh/permutation)


This library includes data types for storing permutations and combinations. It implements pure and impure types, the latter of which can be modified in-place. The library uses aggressive inlining and MutableByteArray#s internally, so it is very efficient.

The main utility of the library is converting between the linear representation of a permutation and a sequence of swaps. This allows, for instance, applying a permutation or its inverse to an array with O(1) memory use.

Much of the interface for the library is based on the permutation and combination functions in the GNU Scientific Library (GSL).
