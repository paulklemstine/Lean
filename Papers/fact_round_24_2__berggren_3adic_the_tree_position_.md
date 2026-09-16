# Computational evidence — BERGGREN-3ADIC (tree position of the N-node)

All numbers below were produced by evaluating the definitions of
`Catalog/Cryptography/Berggren3Adic/*.lean` inside Lean (`#eval`), using the same
`letterOf`, `parentPair`, `evalPair`, `nOf`, `witA/witB/witC`, `spine` that the
theorems are stated about.  The reproduction script is at the end of this file.

## 1. Sample

All 276 pairs `p < q` of odd primes drawn from
`3, 5, …, 97`, i.e. 276 odd semiprimes `N = p q` with `N ≤ 89·97 = 8633`.
Fermat pair of `N`: `(m, n) = ((q+p)/2, (q−p)/2)`, so `N = m² − n²`.

## 2. H1 — the 3-adic skeleton (deterministic)

Check of the three equivalences
`N ≡ 1 (3) ↔ 3 ∣ n`, `N ≡ 2 (3) ↔ 3 ∣ m`, `N ≡ 0 (3) ↔ 3 ∤ m ∧ 3 ∤ n`:

| pairs tested | agreements |
|---|---|
| 276 | **276 / 276 = 100 %** |

Trace restatement `3 ∣ n ↔ p ≡ q (mod 3)`: **276 / 276**.

Both are now theorems: `skeleton`, `skeleton_dvd_n_iff_trace`, `skeleton_is_trace`
(proved for *all* coprime pairs, not only for the sample).

## 3. H2 — parent-interval law and exact descent

Descent by `parentPair` (band decided by `m/n` alone), fuel 5000:

| pairs | reach root `(2,1)` exactly | word re-evaluates to the node | max depth seen |
|---|---|---|---|
| 276 | **276 / 276** | **276 / 276** | 35 |

Proved in `ParentLaw.lean`: `actGen_parentPair`, `parent_unique`, `exists_word`,
`existsUnique_word`, `range_evalPair` — with no fuel cap and no censoring, so the
0.10 % censored twin-type nodes of the original run are covered as well
(they are exactly the `C`-spine nodes, `evalPair_spine`).

## 4. H3 — blindness witnesses

Witness triple `witA M = (M+1, M)`, `witB M = (3M−1, M)`, `witC M = (3M+1, M)`
at `M = 3^k`:

| `M = 3^k` | `N(witA) mod M` | `N(witB) mod M` | `N(witC) mod M` | letters |
|---|---|---|---|---|
| 3 | 1 | 1 | 1 | A, B, C |
| 9 | 1 | 1 | 1 | A, B, C |
| 27 | 1 | 1 | 1 | A, B, C |
| 81 | 1 | 1 | 1 | A, B, C |
| 243 | 1 | 1 | 1 | A, B, C |
| 729 | 1 | 1 | 1 | A, B, C |

So each 3-adic level `3^k`, `k ≤ 6` (and in the theorem, every `k ≥ 1`, indeed
every odd modulus `M ≥ 3`) has a **single residue class containing all three branch
letters**.  `k = 0` is degenerate (`M = 1`, one class) and is excluded.

Depth witnesses on the `C`-spine, `N(spine d) = (2+2d)² − 1`:

| `M = 3^k` | `N(spine (1+M)) − N(spine 1) mod M` | depths compared |
|---|---|---|
| 1 | 0 | 1 vs 2 |
| 3 | 0 | 1 vs 4 |
| 9 | 0 | 1 vs 10 |
| 27 | 0 | 1 vs 28 |
| 81 | 0 | 1 vs 82 |

Small spine table (`d`, node, `N`):
`(0,(2,1),3) (1,(4,1),15) (2,(6,1),35) (3,(8,1),63) (4,(10,1),99) (5,(12,1),143)`;
`N = 4d² + 8d + 3 = (2d+1)(2d+3)`, the product of two odd numbers two apart
(A005563-shifted; the factorisation is manifest, which is the point of the
positive control).

## 5. Counterexample hunt

Searching for a counterexample to blindness means searching for an odd `M ≥ 3` whose
residue classes each carry a *single* letter.  The witness triple above rules this out
for every odd `M ≥ 3` simultaneously, and this is exactly what
`all_letters_in_one_residue_class` proves; no counterexample exists.

Searching for a counterexample to the skeleton lemma over the 276 semiprimes produced
none, consistent with the proof.

## 6. Cycle 2 — the letter is the balance band; proper witnesses at every modulus

Balance law `A ↔ q > 3p`, `B ↔ 2p < q ≤ 3p`, `C ↔ q ≤ 2p` on the same 276 semiprimes:
**276 / 276** (theorem `letter_of_factorization`).

Proper witnesses `pwitA M = (4M−1, 2M)`, `pwitB M = (4M+1, 2M)`, `pwitC M = (6M+1, 2M)`,
which encode the nontrivial factorisations `(2M−1)(6M−1)`, `(2M+1)(6M+1)`,
`(4M+1)(8M+1)`:

| `M` | `N(pwitA) mod M` | `N(pwitB) mod M` | `N(pwitC) mod M` | letters | smaller factors `m−n` |
|---|---|---|---|---|---|
| 2 | 1 | 1 | 1 | A, B, C | 3, 5, 9 |
| 3 | 1 | 1 | 1 | A, B, C | 5, 7, 13 |
| 4 | 1 | 1 | 1 | A, B, C | 7, 9, 17 |
| 5 | 1 | 1 | 1 | A, B, C | 9, 11, 21 |
| … | 1 | 1 | 1 | A, B, C | `2M−1`, `2M+1`, `4M+1` |
| 12 | 1 | 1 | 1 | A, B, C | 23, 25, 49 |

So the seal holds at **every** modulus `M ≥ 2`, even ones included, and on nodes whose
factorisation is nontrivial (`all_letters_in_one_residue_class_proper`).

```lean
def balOK (pq : ℤ × ℤ) : Bool :=
  let p := pq.1; let q := pq.2; let node : ℤ × ℤ := ((q+p)/2, (q-p)/2)
  let L := letterOf node
  ((L == BergGen.A) == decide (3*p < q)) &&
  ((L == BergGen.B) == decide (2*p < q && q ≤ 3*p)) &&
  ((L == BergGen.C) == decide (q ≤ 2*p))
#eval (pairsPQ.length, pairsPQ.countP balOK)   -- (276, 276)

#eval (List.range 11).map (fun i => let M : ℤ := i + 2;
  (M, nOf (pwitA M) % M, nOf (pwitB M) % M, nOf (pwitC M) % M,
      letterOf (pwitA M), letterOf (pwitB M), letterOf (pwitC M)))
```

## 7. Cycle 3 — positionwise seal

Family `node M k t = (4tM + 2Mk + 1, 2M)`.  Letters listed from the node upwards
(`letterAt 0` is the node's own letter):

| `M` | `t` | `k = 1` | `k = 2` | `k = 3` | `N mod M` (all three) |
|---|---|---|---|---|---|
| 2, 3, 9, 27 | 0 | `[A]` | `[B]` | `[C]` | 1 |
| 2, 3, 9, 27 | 1 | `[C, A]` | `[C, B]` | `[C, C]` | 1 |
| 2, 3, 9, 27 | 2 | `[C, C, A]` | `[C, C, B]` | `[C, C, C]` | 1 |
| 2, 3, 9, 27 | 3 | `[C, C, C, A]` | `[C, C, C, B]` | `[C, C, C, C]` | 1 |
| 2, 3, 9, 27 | 4 | `[C,C,C,C,A]` | `[C,C,C,C,B]` | `[C,C,C,C,C]` | 1 |

The three nodes agree in every letter shallower than `t`, lie in one residue class of
`N`, and differ exactly at depth `t` — the content of
`all_letters_at_depth_in_one_residue_class` and `no_depthwise_letter_function`.

```lean
#eval (List.range 5).flatMap (fun t => [2,3,9,27].map (fun M : ℤ =>
  (M, t, (List.range (t+1)).map (fun s => letterAt s (node M 1 t)),
         (List.range (t+1)).map (fun s => letterAt s (node M 2 t)),
         (List.range (t+1)).map (fun s => letterAt s (node M 3 t)),
         nOf (node M 1 t) % M, nOf (node M 2 t) % M, nOf (node M 3 t) % M)))
```

## 8. Reproduction script

```lean
import Cryptography.Berggren3Adic.Blindness
open Berggren3Adic

instance : Repr BergGen := ⟨fun g _ => match g with | .A => "A" | .B => "B" | .C => "C"⟩

def descend : ℕ → ℤ × ℤ → List BergGen × (ℤ × ℤ)
  | 0, p => ([], p)
  | (k+1), p => if p = rootPair then ([], p) else
      let g := letterOf p; let q := parentPair p
      let (w, r) := descend k q
      (w ++ [g], r)

def primes : List ℤ := [3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97]
def pairsPQ : List (ℤ × ℤ) :=
  (primes.flatMap (fun a => primes.map (fun b => (a,b)))).filter (fun x => x.1 < x.2)

def skelOK (pq : ℤ × ℤ) : Bool :=
  let p := pq.1; let q := pq.2
  let m := (q+p)/2; let n := (q-p)/2; let N := p*q
  ((N % 3 == 1) == (n % 3 == 0)) && ((N % 3 == 2) == (m % 3 == 0)) &&
  ((N % 3 == 0) == (!(m % 3 == 0) && !(n % 3 == 0)))

#eval (pairsPQ.length, pairsPQ.countP skelOK)                       -- (276, 276)
#eval pairsPQ.countP (fun pq =>
  (((pq.2-pq.1)/2) % 3 == 0) == (pq.1 % 3 == pq.2 % 3))             -- 276

def descentOK (pq : ℤ × ℤ) : Bool :=
  let node : ℤ × ℤ := ((pq.2+pq.1)/2, (pq.2-pq.1)/2)
  let (w, r) := descend 5000 node
  (r == rootPair) && (evalPair w == node)
#eval pairsPQ.countP descentOK                                      -- 276
#eval (pairsPQ.map (fun pq =>
  (descend 5000 ((pq.2+pq.1)/2, (pq.2-pq.1)/2)).1.length)).foldl max 0  -- 35

#eval (List.range 7).map (fun k => let M : ℤ := 3^k;
  (M, nOf (witA M) % M, nOf (witB M) % M, nOf (witC M) % M,
      letterOf (witA M), letterOf (witB M), letterOf (witC M)))
#eval (List.range 5).map (fun k => let M := 3^k;
  (M, (nOf (evalPair (spine (1 + M))) - nOf (evalPair (spine 1))) % (M:ℤ), 1 + M))
```
