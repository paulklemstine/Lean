#!/usr/bin/env python3
"""
Q3 CORRECTED.  Q3b had a modelling error: it priced relation collection as
|FB| trial divisions PER CANDIDATE.  That is the SIEVE-FREE model.  Real NFS
relation collection SIEVES the box: the cost is
    Y^2 * (sieve marks) + (survivors) * (trial divisions)
where sieve marks ~ Y^2 * sum_{p<B} 1/p ~ Y^2 * ln ln B, and the trial-division
term acts only on the ~Y^2*yield survivors.  The |FB| term is therefore NOT
multiplied by Y^2.  This changes Q3 completely.
"""
import math, sys
sys.path.insert(0,'/home/raver1975/lean/factor-scratch/r52/exp/relof')

print("="*78)
print("WHY Q3b WAS WRONG")
print("="*78)
print("  Q3b priced cost = Y^2 * |FB|.  That is the no-sieve cost model.")
print("  Real NFS: sieve the box once (cost Y^2*lnlnB), then trial-divide only the")
print("  SURVIVORS.  With exact yield  y = Psi(V,B)/V,  survivors ~ Y^2 * y.")
print("  cost = Y^2 * [ lnlnB + y * |FB| ]")
print("  At the NFS optimum the two terms are BALANCED BY CONSTRUCTION -- that is")
print("  exactly what the 'optimal' ln B in the L[1/3] derivation enforces.")
print()
print("  => The |FB|-per-candidate term is already amortised to ~lnlnB scale.")
print("     Batch smoothness attacks a term that is NOT dominant.")
print()

print("="*78)
print("Q3 -- the two cost terms at the NFS optimum (u = lnV/lnB fixed)")
print("="*78)
print("  At the L[1/3] optimum, u = lnV/lnB takes the value that equalises the")
print("  relation-supply and sieving terms.  Quote both terms per candidate:")
print()
print(f"{'lnB':>7} {'u':>6} {'sieve/cand (lnlnB)':>19} {'trial/cand (y*|FB|/Y^2)':>23} {'ratio':>8}")
from sympy import primepi
def rho(u):
    from q1_theory import dickman_rho
    return dickman_rho(u)
for lnb in [15,20,25,30,35,40]:
    B=int(math.exp(lnb))
    fb=primepi(B)
    # V = B^u ; choose the u that the standard derivation gives (~ 4-5 for GNFS)
    for u in [4.0]:
        y=rho(u)
        sieve=math.log(math.log(B))          # ln ln B
        # survivors per candidate ~ y; trial divisions per survivor ~ |FB|;
        # but the SIEVE has already removed most, so the residual trial work is
        # bounded by the number of primes NOT sieved (~ |FB| - sieved) times y
        trial=y*fb
        print(f"{lnb:>7} {u:>6.1f} {sieve:>19.3f} {trial:>23.3e} {trial/sieve:>8.1f}")
print()
print("  Read: per candidate the sieve term is O(ln ln B) ~ 3, and the residual")
print("  trial term is y*|FB| which is ENORMOUS if charged per candidate.")
print("  But it is NOT charged per candidate -- it is charged per SURVIVOR, and")
print("  survivors are rare.  The correct per-candidate normalisation is the")
print("  ratio (y*|FB|)/(Y^2) ... which is what the L[1/3] balance sets.")
print()

print("="*78)
print("THE DECISIVE ARGUMENT (no modelling needed)")
print("="*78)
print("  The standard NFS derivation ALREADY contains the batch/segmented sieve:")
print("  the whole point of L[1/3] is that the factor base is sieved, not trial")
print("  divided, and the derivation's per-candidate cost is O(1) modular work.")
print()
print("  Bernstein batch smoothness replaces trial division by a SEGMENTED SIEVE")
print("  over a range of consecutive values.  A segmented sieve over [x, x+W] costs")
print("  O(W loglogB + pi(B)) -- i.e. the pi(B) setup is paid ONCE for W candidates.")
print("  NFS relation finding ALREADY does this: the box IS the range, and the")
print("  FB sieve is applied to the whole box at once.")
print()
print("  => Batch smoothness is not an improvement to NFS relation finding; it is")
print("     what NFS relation finding already is.  There is nothing left to amortise.")
print()
print("  The residual question NFS actually has: the LARGE-PRIME cofactor. After")
print("  sieving to B, a survivor carries one prime > B.  Those are paired into")
print("  'large prime relations', which is the double-large-prime variation.")
print("  THAT is the batch-smoothness-analogue already in the state of the art.")
