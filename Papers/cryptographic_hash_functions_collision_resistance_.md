# Theorem Trace (internal anti-hallucination ledger)

Every theorem/definition below is taken verbatim from the Phase A Lean output:
`Catalog/Cryptography/ClawFreeHash.lean` and its dependency
`Catalog/Cryptography/MerkleDamgard.lean` (read from disk). The
`MDLengthExtension.lean` names are described only in the Phase A future-directions
block; they are mentioned in prose ONLY as future/related work, never stated as
proved results here.

## MerkleDamgard.lean (dependency, fully present on disk)

| Lean name | Statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `mdHash` (def) | `mdHash f iv msg = msg.foldl f iv` — iterated hash | yes | yes |
| `HasCompressionCollision` (def) | `∃ s b s' b', (s,b)≠(s',b') ∧ f s b = f s' b'` | yes | yes |
| `mdHash_nil` | `mdHash f iv [] = iv` | implicit | yes |
| `mdHash_concat` | `mdHash f iv (l ++ [b]) = f (mdHash f iv l) b` | no | yes |
| `mdHash_append` | `mdHash f iv (a++b) = mdHash f (mdHash f iv a) b` | no | yes |
| `md_collision_extract` | equal-length MD collision ⇒ compression collision | yes | yes |
| `mdHash_injOn_length` | no compression collision ⇒ MD injective per length | yes | yes |
| `compression_collision_of_card` | finite pigeonhole: collisions always exist | yes | yes |

## ClawFreeHash.lean (headline file, from Phase A output)

| Lean name | Statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `IsClaw` (def) | `IsClaw g₀ g₁ x y := g₀ x = g₁ y` | yes | yes |
| `HasClaw` (def) | `HasClaw g₀ g₁ := ∃ x y, g₀ x = g₁ y` | yes | yes |
| `clawCompress` (def) | `clawCompress g₀ g₁ s b = bif b then g₁ s else g₀ s` | yes | yes |
| `clawCompress_false` | `clawCompress g₀ g₁ s false = g₀ s` | no | yes |
| `clawCompress_true` | `clawCompress g₀ g₁ s true = g₁ s` | no | yes |
| `claw_to_compression_collision` | claw ⇒ compression collision | yes | yes |
| `clawCompress_collision_to_claw` | injective pair: compression collision ⇒ claw | yes | yes |
| `claw_iff_compression_collision` | injective pair: claw ⇔ compression collision | yes (main) | yes (main) |
| `clawFree_compression_collisionFree` | claw-free ⇒ compression collision-free | yes | yes |
| `md_clawCompress_collision_to_claw` | MD collision (equal len) ⇒ claw | yes | yes |
| `clawFree_mdHash_injOn_length` | claw-free ⇒ MD injective per length (HEADLINE) | yes (main) | yes (main) |
| `g0Ex` (def) | `id : ZMod 2 → ZMod 2` | yes | yes |
| `g1Ex` (def) | `(· + 1) : ZMod 2 → ZMod 2` | yes | yes |
| `g0Ex_injective` | `Injective g0Ex` | no | yes |
| `g1Ex_injective` | `Injective g1Ex` | no | yes |
| `concrete_claw` | `HasClaw g0Ex g1Ex` (g0Ex 1 = g1Ex 0 = 1) | yes | yes |
| `concrete_compression_collision` | `HasCompressionCollision (clawCompress g0Ex g1Ex)` | yes | yes |

## Related / future only (NOT stated as proved here)
- `md_collision_family`, `injectiveOracle_no_collision`, `finalize_collision_iff`
  — from `MDLengthExtension.lean`; appear only in Future Directions text.
