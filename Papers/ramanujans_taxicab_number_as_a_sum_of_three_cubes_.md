# Computational Evidence: 1729 as Three Cubes

## Small-case calculations

The classical decompositions are

| form | value |
|---|---:|
| \(12^3+1^3\) | \(1728+1=1729\) |
| \(10^3+9^3\) | \(1000+729=1729\) |

Allowing nonzero signed terms produces

| \(x\) | \(y\) | \(z\) | cubes | sum | height |
|---:|---:|---:|---|---:|---:|
| 13 | -7 | -5 | \(2197,-343,-125\) | 1729 | 13 |

Thus the proposed nonexistence claim fails.  The three entries are nonzero,
pairwise distinct, and have greatest common divisor one.

## Counterexample hunt

An exhaustive search of the integer box \([-12,12]^3\), excluding zero
coordinates, found no solution.  Expanding to \([-13,13]^3\) found exactly the
six ordered permutations of \((13,-7,-5)\).  Consequently 13 is the minimum
possible height of a nonzero signed representation.

A broader exploratory search through absolute coordinate size 2000 found a
second unordered candidate orbit, \((-215,98,208)\), since
\((-215)^3+98^3+208^3=1729\).  This broader observation is recorded as a target
for future classification rather than used in the present sharp theorem.

## Residue checks

Since \(1729\equiv1\pmod 9\), it avoids the universal forbidden residues 4 and 5.
More strongly, reducing the displayed integral triple modulo any positive
modulus gives a local solution.  This supplies direct evidence at every finite
level, not merely at a selected list of small primes.

## Sequence search

No OEIS identification is needed for the main result: it is a single explicit
Diophantine identity and a bounded classification, rather than an inferred
sequence.  The natural sequence for subsequent study is the ordered list of
heights of primitive permutation-orbits on the fixed cubic surface; the first
two observed candidate heights are 13 and 215, but a complete identification
has not been asserted.
