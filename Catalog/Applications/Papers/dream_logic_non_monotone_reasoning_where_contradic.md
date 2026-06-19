# Computational Evidence — Dream Logic

Concise numerical/sanity evidence gathered before formalization.

## 1. Belnap `FOUR` truth tables (small-case enumeration)

Values: `T = true`, `F = false`, `B = both` (glut), `N = neither` (gap).
Designated `D = {T, B}`. Negation `¬`: `¬T=F, ¬F=T, ¬B=B, ¬N=N`.

Conjunction `∧` (meet in truth order `F < B,N < T`):

```
∧ | T  F  B  N
--+-------------
T | T  F  B  N
F | F  F  F  F
B | B  F  B  F
N | N  F  F  N
```

Contradiction column `x ∧ ¬x` and designation:

```
x  | ¬x | x∧¬x | designated?
T  | F  |  F   |  no
F  | T  |  F   |  no
B  | B  |  B   |  YES   <- glut: contradiction accepted, explosion blocked
N  | N  |  N   |  no
```

Only `B` makes `x ∧ ¬x` designated → `glut_iff` (unique glut).
Dually, only `N` makes `x ∨ ¬x` non-designated → `gap_iff` (unique gap).
Explosion witness: `(x,y) = (B,F)` — `B∧¬B = B` designated, `F` not. Confirmed.

## 2. Topological model — frontier = contradiction set

For closed `A`, `contradiction A := A ∩ closure Aᶜ = frontier A`.

| space | closed `A`        | `frontier A`     | contradiction? |
|-------|-------------------|------------------|----------------|
| ℝ     | `[0,1]`           | `{0,1}`          | nonempty (glut)|
| ℝ     | `[0,1] ∪ [2,3]`   | `{0,1,2,3}`      | nonempty       |
| ℝ     | `∅`               | `∅`              | empty (clopen) |
| ℝ     | `univ`            | `∅`              | empty (clopen) |
| ℝ     | `{pt}`            | `{pt}`           | nonempty       |
| 2-pt discrete | `{a}`     | `∅`              | empty (clopen) |

Pattern: contradiction empty ⇔ `A` clopen (`lnc_holds_iff_clopen`). On the
connected space ℝ the only clopen sets are `∅` and `univ`, so *every* proper
nonempty closed set is dialetheic (`connected_forces_paraconsistency`).

## 3. Counterexample hunt on the briefing's literal claim

Claim as literally worded: "open sets are not closed under arbitrary union."
This is **false** by the axioms of a topology (arbitrary unions of opens are
open). Tested mentally on ℝ, discrete, indiscrete — all closed under arbitrary
union of opens. The salvageable dual statement, verified above, is "closed sets
need not be clopen", which is what the formalization proves. Logged in Stage 3
Lab Notes as a "needs a different definition" outcome.

## 4. OEIS

No integer sequence is central to this cycle (the objects are a fixed 4-element
algebra and topological boundaries), so no OEIS lookup applies. The clopen-count
function from Conjecture 1 (`X ↦ |clopen X|`) for finite spaces would be the
natural sequence to register in a follow-up cycle.

All checks above were reproduced as Lean theorems with 0 sorries; the markdown is
only an informal pre-registration of the expected results.
