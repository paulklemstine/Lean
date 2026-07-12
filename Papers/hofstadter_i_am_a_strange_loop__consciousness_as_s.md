# Computational Evidence — Strange Loops / Self-Reference

The project's claims are *universal structural* statements (Lawvere's
fixed-point theorem and its corollaries, plus a finite combinatorial fact about
minimum loop length). We give concrete small-case checks that motivated and
sanity-checked each formalized theorem.

## 1. The diagonal engine (Lawvere / Cantor), tiny cases

For a finite state space `A` with `|A| = k` and observation space `B` with
`|B| = m`, a point-surjection `A → (A → B)` would require the `k` codes to name
all `m^k` behaviours, i.e. `k ≥ m^k`.

| k | m | m^k | possible? |
|---|---|-----|-----------|
| 1 | 2 | 2   | no (1 < 2) |
| 2 | 2 | 4   | no (2 < 4) |
| 3 | 2 | 8   | no |
| k | 2 | 2^k | never, since `2^k > k` for all `k ≥ 0` |

So already by counting, no finite system can boolean-self-model completely —
consistent with `cantor_bool`. Lawvere strengthens this to arbitrary `A`
(including infinite) by exhibiting the explicit missing behaviour
`fun x => !(f x x)` (`diagonal_not_representable`).

**Diagonal witness, k = 2 example.** Let `A = {0,1}`, `f 0 = (fun _ => false)`,
`f 1 = (fun _ => false)`. Then `f 0 0 = false`, `f 1 1 = false`, so the
diagonal `d x = !(f x x)` is the constant `true`, which equals neither `f 0`
nor `f 1`. Missing, as predicted.

## 2. Minimum strange-loop length = 3

Search over asymmetric relations (`R a b → ¬ R b a`) for the shortest closed
loop `v_0 → v_1 → … → v_0`:

- **Length 1** needs `R x x`; asymmetry ⇒ irreflexive ⇒ impossible.
- **Length 2** needs `R a b` and `R b a`; directly forbidden by asymmetry.
- **Length 3** is realized by rock-paper-scissors on `ZMod 3`:
  `0 → 1 → 2 → 0` with `R a b ⇔ b = a+1`. Check asymmetry: `b = a+1` and
  `a = b+1` would give `a = a+2`, i.e. `2 ≡ 0 (mod 3)` — false. ✓
- **Length n ≥ 3** is realized identically on `ZMod n` (`succ` relation); the
  asymmetry check reduces to `n ∤ 2`, true for all `n ≥ 3`.

So the minimal length is exactly 3, and every larger length is attainable.
This is formalized in `min_loop_length` and `exists_loop_len`.

**Transitivity check.** The `ZMod 3` successor relation is *not* transitive:
`0 → 1` and `1 → 2` but not `0 → 2` (since `2 ≠ 0+1`). A transitive +
irreflexive relation (a strict order) has *no* loop of any length
(`strictOrder_no_loop`) — consistent with "strange loops require a tangled,
non-transitive hierarchy".

## 3. Counterexample hunt

- Attempted to find a *transitive* asymmetric relation with any closed loop:
  none exists (proved: `strictOrder_no_loop`). No counterexample.
- Attempted to find an asymmetric relation with a length-1 or length-2 loop:
  none exists (proved: `no_loop_len1`, `no_loop_len2`). No counterexample.
- Attempted to find a fixed point of `!·` on `Bool` or `¬·` on `Prop`: none
  (`by decide`; `tauto`). No counterexample — confirming the negative face.

## 4. OEIS

No integer sequence is central to the theorems. The only counting side-remark,
`2^k > k`, is the standard cardinality gap behind Cantor and needs no lookup.

All numeric checks above are reproduced as machine-checked Lean proofs
(`by decide`, explicit witnesses, `omega`) in the accompanying `.lean` files.
