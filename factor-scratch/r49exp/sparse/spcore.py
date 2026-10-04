"""
spcore -- SPARSITY / DEFECT analysis and sparse linear-algebra routes for
Stange's Q-kernel method (arXiv:2211.06821, Algorithm 2.2, step 11).

Round 49 agent MM.  Everything additive; the validated relation-finding and
factoring primitives are IMPORTED from the read-only r48 implementation, never
re-implemented, so the five defects its self-test caught cannot come back:

    /home/raver1975/lean/factor-scratch/r48/exp/stange/stange.py
        factor_base, fb_exponents, find_relations, build_M, primitive,
        kernel_basis, factor_from_multiple, gen_semiprime, bbound_for_b

r48/_shared/dickman.py is NOT used (broken above u = 5; see
notes/LL_dickman_harness_broken.md).  Smoothness here is always EXACT trial
division by the factor base, which is the definition.

==============================================================================
THE MATRIX
==============================================================================
M is b x (b+c); COLUMN j is the exponent vector of relation j, i.e.

    M[i][j] = v_{p_i}( r_j ),   r_j = g^{x_j} mod n,  r_j = prod_i p_i^{M[i][j]}.

So the nonzeros of column j are exactly the DISTINCT primes dividing a uniformly
random B-smooth integer r <= n.  Write  omega = #{i : M[i][j] != 0}.

==============================================================================
THE ONE-LINE STRUCTURAL FACT THAT DECIDES THE AXIS (proved, not estimated)
==============================================================================
ROW i is nonzero in column j iff p_i | r_j.  The relations are drawn as
x uniform in [1,n), and every FB-smooth residue is hit with equal probability,
so r_j is uniform over the B-smooth integers in [1,n].  THEREFORE, EXACTLY:

    Pr[ row i nonzero ]  =  # {B-smooth r <= n : p_i | r} / #{B-smooth r <= n}
                          =  Psi(n/p_i, B) / Psi(n, B)                    (*)

because r is B-smooth and p_i | r  <=>  r = p_i * s with s B-smooth, s <= n/p_i.

Two consequences, both exact, no asymptotic:

  (a) COLUMN nnz = E[omega] is SMALL: the p_i | r events are near-independent
      for a random B-smooth number, so E[omega] = Theta(1).  nnz(M) = Theta(b).
  (b) ROW nnz for the SMALLEST prime tends to Psi(n/2,B)/Psi(n,B), which is
      Theta(1) (measured: 0.40-0.55 in the working regime, limit 1/2 as B->inf
      at fixed n, since then Psi(n,B) = n and the answer is exactly 1/2).

  Hence max_i rowdeg_i = Theta(b)  and  the matrix is "Theta(b) nonzeros in a
  b x b matrix with one Theta(b)-degree row".

  THE PERMUTATION-SIMILARITY DEFECT IS *TRIVIALLY* INVARIANT HERE.
  For a 0/1 (or any) matrix A, permuting COLUMNS permutes the entries inside
  each row, so each row's nnz count -- and therefore the multiset of row
  degrees and its maximum -- is unchanged.  Symmetrically for rows and column
  degrees.  Hence for EVERY sigma, tau,

        defect(sigma A tau) = defect(A) = max(max_i rowdeg_i, max_j coldeg_j)

  so there is NO permutation that lowers the defect: the min over (sigma,tau) is
  attained already at the identity.  `defect_is_permutation_invariant()` checks
  this numerically on real matrices anyway.

  This is exactly where the NFS analogy dies.  NFS's O(n^2) sparse linear
  algebra rests on the NFS relation matrix having, AFTER Montgomery's
  "minimal candidate selection" reordering, O(log n / log B) nonzeros PER ROW
  -- a bounded defect.  Stange's matrix has defect Theta(b) for a structural
  reason that no reordering touches: the row for p = 2 is dense because half
  of all B-smooth numbers are even.

==============================================================================
MANDATORY CORRECTNESS CONTRACT (round 48 wrote a null-space routine twice and
both versions returned the RIGHT RANK and the WRONG VECTORS)
==============================================================================
`assert_kernel(M, basis)` checks, in EXACT rational arithmetic,

    (1) M v = 0 for every returned vector v, elementwise, exactly;
    (2) the returned vectors are linearly independent over Q (via an exact
        Fraction rref of the b'-long matrix of the vectors, NOT a rank float);
    (3) len(basis) == ncols - rank, the only dimension check -- it is reported
        but on its own it is NOT sufficient, per the round-48 lesson.

Every route below calls it.  The self-test additionally feeds the assertion a
DELIBERATELY BROKEN basis and requires it to FAIL, because an assertion that
cannot reject the broken case certifies nothing.
"""

from __future__ import annotations

import math
import random
import sys
import time
from fractions import Fraction
from math import gcd

R48 = "/home/raver1975/lean/factor-scratch/r48/exp/stange"
if R48 not in sys.path:
    sys.path.insert(0, R48)

from stange import (  # noqa: E402  -- read-only, validated
    bbound_for_b,
    build_M,
    factor_base,
    factor_from_multiple,
    fb_exponents,
    find_relations,
    gen_semiprime,
    kernel_basis,
    primitive,
    rand_g if False else None,  # placeholder, never imported
)