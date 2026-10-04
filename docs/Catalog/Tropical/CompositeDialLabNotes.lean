import Mathlib

/-!
# Lab notes for COMPOSITE-DIAL: kernel-checked fibre counts

Brute-force companion to `Tropical.CompositeDialLegendre`.  Everything is computed on
plain natural numbers (no CRT model): a unit `a mod N` is listed directly, its Legendre
bits are computed by searching for square roots, and its Jacobi parity is the parity of
the number of prime factors modulo which `a` is a nonresidue.  The equalities below are
checked by `decide` (kernel evaluation) and corroborate the general theorems:

* `N = 15`: every pair (residue mod 3, label) and (residue mod 5, label) has the same
  count — the components are blind (`semiprime_whole_exceeds_sum`).
* `N = 105`: the pair (residue mod 15 = residues mod 3 and mod 5, label) is
  equidistributed on every unit class — a *pair* of components is blind
  (`three_prime_pairs_blind`).
* Both labels occur equally often (`24 / 24` for `N = 105`), so the whole carries
  exactly one bit.
-/

namespace CompositeDial.LabNotes

/-- `a` is a quadratic residue modulo `p` (search for a square root). -/
def isQR (p a : ℕ) : Bool := (List.range p).any fun x => x * x % p == a % p

/-- Jacobi parity of `a` for the squarefree modulus `∏ ps`. -/
def jbit (ps : List ℕ) (a : ℕ) : ℕ := (ps.filter fun p => !isQR p a).length % 2

/-- The units modulo `∏ ps`. -/
def units (ps : List ℕ) : List ℕ := (List.range ps.prod).filter fun a => Nat.gcd a ps.prod == 1

/-- Number of units `a` with `a % m = r` and Jacobi parity `b`. -/
def cnt (ps : List ℕ) (m r b : ℕ) : ℕ :=
  ((units ps).filter fun a => a % m == r && jbit ps a == b).length

/-- `N = 15`, residue mod 3 vs label: flat `2/2/2/2` table. -/
theorem semiprime15_mod3_flat :
    [(1, 0), (1, 1), (2, 0), (2, 1)].map (fun rb => cnt [3, 5] 3 rb.1 rb.2) = [2, 2, 2, 2] := by
  decide

/-- `N = 15`, residue mod 5 vs label: flat table. -/
theorem semiprime15_mod5_flat :
    [(1, 0), (1, 1), (2, 0), (2, 1), (3, 0), (3, 1), (4, 0), (4, 1)].map
      (fun rb => cnt [3, 5] 5 rb.1 rb.2) = [1, 1, 1, 1, 1, 1, 1, 1] := by
  decide

/-- `N = 105`, residue mod 15 (a *pair* of components) vs label: for every class `r`
the two label counts agree. -/
theorem triprime105_pair_flat :
    (List.range 15).map (fun r => cnt [3, 5, 7] 15 r 0) =
      (List.range 15).map (fun r => cnt [3, 5, 7] 15 r 1) := by
  decide

/-- `N = 105`: both labels have `24` units each (the label is a fair bit). -/
theorem triprime105_label_fair :
    cnt [3, 5, 7] 1 0 0 = 24 ∧ cnt [3, 5, 7] 1 0 1 = 24 := by
  decide

end CompositeDial.LabNotes