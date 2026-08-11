# Computational Evidence — Algorithmic Immune System

All numbers below were produced by executing the Lean development itself
(`Catalog/Shared/ImmuneLabNotes.lean`, whose `#eval`s print exactly this data and
whose `example`s are closed by kernel evaluation with `decide`).  No external
scripts were used, so every figure here is backed by a compiled Lean artifact.

## 1. Attestation tags (Part I, `PAst.code`)

| AST | tag |
|---|---|
| `inp` | 0 |
| `attack` | 1 |
| `lit 0` | 2 |
| `lit 7` | 37 |
| `ite (lit 0) attack (lit 3)` | 1483 |
| `call (lit 2) inp` | 784 |

Distinctness of these tags is verified by `decide`, in line with the proved
theorem `code_injective` (residues mod 5 separate constructors, Cantor pairing
separates payloads).

## 2. The detector dilemma, executed (Part III)

| detector `d` | verdict on its diagonal parasite | `run (parasite d [])` |
|---|---|---|
| `lit 0` (silent: accuses nobody) | cleared | `true` — a real attack is missed |
| `lit 1` (paranoid: accuses everybody) | accused | `false` — the accusation is a false alarm |

Padded parasites of the silent detector, `run (parasite (lit 0) (replicate n true))`
for `n = 0,1,2,3`: `[true, true, true, true]` — every member of the exponential
escape family really does attack, matching `escape_card_exp`.

## 3. Program sizes

`size (parasite (lit 0) (replicate n true))` for `n = 0..4`: `[6, 9, 12, 15, 18]`,
i.e. `size d + 3n + 5` with `size (lit 0) = 1`, confirming `size_parasite`.

`size (pad (replicate n true))` for `n = 0..4`: `[1, 4, 7, 10, 13] = 3n + 1`,
confirming `size_pad`.

## 4. The benign padded family (Part IV)

For `n = 3` there are `2^3 = 8` bit lists, and the corresponding attestation tags are

```
[2419908966763, 3879595375552926763, 2421404927088, 3879597269407937088,
 2419908966978, 3879595375552926978, 2421404927303, 3879597269407937303]
```

— eight pairwise distinct tags for eight programs that are *behaviourally
identical* (all evaluate to `0` and are effect-free; checked by `decide` at input
`17`).  This is the executed form of `card_padFamily`/`semClass_card_exp` and of
the uncertainty principle `2 ^ n ≤ |S| + |padFamily n \ S|`.

## 5. Counterexample hunt / adversarial simulation (Part IV)

Sanctioned set `demoS = {lit 0, lit 5}`, baseline `lit 0`, adversary
`demoAdv n t = if n even then ite (lit 1) attack t else lit 5` (it splices a live
`attack` into the running code at every even step).

Guarded run `trace demoS (lit 0) demoAdv n`, `n = 0..5`:

```
[lit 0, lit 0, lit 5, lit 0, lit 5, lit 0]
```

Executed effects `effect (trace …) 0` for the same steps:

```
[false, false, false, false, false, false]
```

Both containment (`∈ demoS` at every step) and zero forbidden actions are
verified by `decide`, while the *unguarded* first mutation is already lethal:
`run (demoAdv 0 (lit 0)) = true`.  This is the executed instance of
`trace_mem` / `neutralization`.

## 6. Counterexample hunt against the conjectures

* *Can a syntactic monitor be semantics-invariant?*  No: item 4 exhibits `2^n`
  behaviourally identical programs with pairwise distinct tags.  The conjecture
  "attestation can be made semantically closed while finite" was refuted, and the
  refutation became the theorem `finite_whitelist_not_semantically_closed`.
* *Can ensembles/voting repair detection?*  No: `ensemble_common_escape` and the
  executed silent/paranoid pair in item 2 show a single program on which all
  members err simultaneously.
* *Is sampled monitoring safe?*  No: an adversary emitting `attack` at every step
  keeps the system compromised at all non-checkpoint times (`attack_window`);
  only period `1` is safe (`monitoring_frequency_dichotomy`).
* No sequence arising here matched a nontrivial OEIS entry: the counts obtained
  are `2^n` (escape/padding families) and `3n+1`, `3n+5` (sizes), all elementary.

## 7. What the evidence did *not* settle

The evidence is finite; the exponential lower bounds, the diagonal impossibility
and the reflexive oracle barrier are established by the proofs in
`Catalog/Shared/Immune*.lean`, not by these computations.  The computations were
used to (i) sanity-check every definition before proving anything about it and
(ii) confirm that the diagonal parasite is a genuinely executing program rather
than a vacuous construction.
