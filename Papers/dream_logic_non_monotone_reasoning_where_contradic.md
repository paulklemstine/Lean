# Computational Evidence — Dream Logic

## 1. Four-valued truth tables (small-case verification)

Values: `tt`, `ff`, `both` (glut), `neither` (gap). Negation fixes the glut and gap:

```
neg:  tt↦ff   ff↦tt   both↦both   neither↦neither
```

Conjunction = meet, disjunction = join of the truth order `ff < {both,neither} < tt`:

```
conj | tt   ff   both  neither        disj | tt  ff       both  neither
-----+---------------------------      -----+------------------------------
tt   | tt   ff   both  neither         tt   | tt  tt       tt    tt
ff   | ff   ff   ff    ff              ff   | tt  ff       both  neither
both | both ff   both  ff              both | tt  both     both  tt
nei  | nei  ff   ff    neither         nei  | tt  neither  tt    neither
```

Designated (accepted) values: `{tt, both}`.

Contradiction column `conj a (neg a)`:

```
a        : tt  ff  both  neither
conj a ¬a : ff  ff  both  ff
designated:  0   0    1     0
```

So `both` makes a contradiction designated (LNC fails) while `ff` stays non-designated
(explosion fails). Excluded middle `disj a (neg a)`:

```
a        : tt  ff  both  neither
disj a ¬a : tt  tt  both  neither
designated:  1   1    1     0
```

`neither` breaks excluded middle (paracompleteness). These tables are reproduced exactly by
the case-analysis proofs in `FourValued.lean`.

## 2. Closed-set model over ℝ (representative computations)

Take `A = [0,1]`, negation `pneg A = closure(Aᶜ) = (-∞,0] ∪ [1,∞)`.

- `A ∩ pneg A = {0,1}` — nonempty, so a contradiction coexists (boundary points).
- `A ∪ pneg A = ℝ` — excluded middle survives.
- These equal `frontier A = {0,1}`, matching the general "gluts are frontiers" identity.

Union-closure test: `⋃ₙ [1/(n+1), 1]`:

```
n : 0 → [1,1]         partial union up to n
    1 → [1/2,1]
    2 → [1/3,1]
    ...
limit                 (0,1]   — NOT closed (0 is a limit point, absent)
```

So arbitrary unions of closed sets need not be closed; this is the structural counterexample
formalized in `closed_not_iUnion_closed`.

## 3. Counterexample hunt

- Searched for a designated value making explosion hold: none — `ff` and `neither` remain
  non-designated regardless of the contradiction, so explosion has no witness. Confirmed by
  the exhaustive four-case tables above.
- Searched for a closed region with empty frontier but nonempty proper interior on ℝ: none
  in a connected space other than `∅` and `ℝ`; consistent with "gluts = frontiers".

## Note

The evidence is intentionally brief: the claims are finite/exact and are discharged by exact
case analysis and explicit topological witnesses in the accompanying proofs, so no
large-scale numerical search is needed.
