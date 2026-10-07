# Computational evidence — NET-49 (real-model knee collapse and saturation)

The empirical inputs are the NET-49 measurements as reported in the assignment (Qwen2.5-0.5B, wikitext-103,
gate 0.98). The arithmetic below was done in a scratch Python session. It is **not** Lean-verified, except where a
row names a Lean theorem in `Catalog/Geometry/RealModelKneeSaturation.lean`.

## 1. Toy law vs measured knee

| ctx | k\* (measured) | d·ctx/32 (d = 24) | ratio | uniform share k\*/ctx | τ − k\*/ctx (selection-gap floor) |
|---|---|---|---|---|---|
| 512 | 16 | 384 | 24 | 0.03125 | 0.94875 |
| 1024 | 32 | 768 | 24 | 0.03125 | 0.94875 |
| 2048 | 24 | 1536 | 64 | 0.01172 | 0.96828 (Lean: `net49_selection_gap`, > 0.968) |

## 2. Depth multiplier in the power-law tail model (c = 1, g = 0.98)

Window `[g·m·c/(1−g) − c, ⌈m·c/(1−g)⌉]` for the depth-compounded knee when `m` layers carry the tail
(Lean: `toy_depth_knee_lower`, `toy_depth_knee_upper`, `collapsed_depth_knee_upper`):

| m tail layers | lower | upper |
|---|---|---|
| 1 | 48 | 50 |
| 2 (L22/L23 only) | 97 | 100 |
| 24 (all layers, toy) | 1175 | 1200 |

The window is linear in `m`, so collapsing from 24 tail layers to 2 cuts the knee by a factor of 12. The absolute
scale depends on the tail constant `c`, which was not fitted to the data.

## 3. Depth map in mass units (Cauchy–Schwarz: mass ≤ √(k/N_eff))

| layer / ctx | N_eff | max mass kept by 24 keys |
|---|---|---|
| L22 @ 512 | 51 | 0.686 |
| L22 @ 1024 | 83 | 0.538 |
| L22 @ 2048 | 128.5 | 0.432 (Lean: `net49_L22_mass_at_knee`, < 0.433) |
| median layer | 12 | needs ≥ 0.98²·12 = 11.52, so ≥ 12 keys for 98 % mass (Lean: `net49_median_layer_mass_knee`) |

## 4. Counterexample hunt

* **Does a declining knee contradict a fixed profile?** Yes: `kstar_mono_context` proves the knee is monotone in
  the context length for every fixed positive sorted profile. A strict decline 32 → 24 therefore forces the profile
  itself to change (`knee_decline_forces_profile_change`).
* **Is the decline certified?** No. The 1024 sweep gives the bracket (16, 32] and the 2048 sweep gives (16, 24].
  These brackets overlap at 24 (`net49_brackets`), so flat saturation at 24 is equally consistent with the data.
* **Exact flatness `k*(2n) = k*(n)`** fails in general, because the normaliser creeps up with `n` (catalog analyst
  note in `Shared.AttentionBudgetKnee`). The right invariant is "eventually constant"
  (`kstar_eventually_constant_of_geometric_decay`).

No OEIS sequence is relevant here (the objects are real-valued profiles).
