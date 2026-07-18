# Computational Evidence: Parameter-Four Logistic Dynamics

## Small-case calculations

Exact rational arithmetic gives the following initial orbit segments for
\(f(x)=4x(1-x)\):

| seed | first six states |
|---|---|
| \(0\) | \(0,0,0,0,0,0\) |
| \(1/2\) | \(1/2,1,0,0,0,0\) |
| \(1/4\) | \(1/4,3/4,3/4,3/4,3/4,3/4\) |
| \(3/4\) | \(3/4,3/4,3/4,3/4,3/4,3/4\) |
| \(1/10\) | \(1/10,9/25,576/625,112896/390625,\ldots\) |
| \(9/10\) | \(9/10,9/25,576/625,112896/390625,\ldots\) |

The last pair exhibits the exact reflection collision \(f(x)=f(1-x)\).

## Counterexample hunt

Three proposed universal claims fail immediately:

1. Seed-independent convergence to a continuous invariant distribution fails for the
   seed zero, whose empirical distribution is concentrated at zero.
2. A precision-based period lower bound fails for exceptional seeds: zero has period
   one, while one-half enters that orbit after two updates.
3. Seed recovery is not uniquely defined from a positive-time keystream because
   reflected seeds have identical suffixes.

The exact computations also reveal the nonzero fixed point \(3/4\), reached from
\(1/4\) in one update.

## Structural test

The identity
\[
f(\sin^2\theta)=\sin^2(2\theta)
\]
predicts every iterate as \(f^n(\sin^2\theta)=\sin^2(2^n\theta)\). This was promoted
to a general theorem, as were reflection collisions, exceptional orbits, and the
finite-state repetition upper bound.

## Sequence-database search

No OEIS lookup is applicable: the principal objects are real or rational dynamical
orbits depending on a seed, rather than a single canonical integer sequence. No OEIS
identifier is asserted.
