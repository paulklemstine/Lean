# 🔮 The Mathematics of Prediction

## A Unified Formal Framework for Forecasting — Verified in Lean 4

> *"The best prediction is the one that minimizes expected loss."*
> — The Oracle's First Law (formally proven)

---

## Overview

This project provides a comprehensive, machine-verified mathematical framework for the science of prediction. Every core theorem is proven in Lean 4 with Mathlib — no sorry, no hand-waving, no hidden assumptions.

## Project Structure

### Lean Formalizations (all sorry-free ✓)

| File | Topic | Key Theorems |
|------|-------|-------------|
| `PredictionGeometry.lean` | Oracle algebra, Lyapunov horizons, entropy | Idempotent oracles, horizon bounds, max entropy |
| `BayesOptimal.lean` | Bayesian prediction, scoring rules | **Brier score optimality**, ambiguity decomposition |
| `PredictionLimits.lean` | Computational & chaotic limits | Unpredictable sequences, chaos growth, Fano inequality |
| `MartingalePrediction.lean` | Martingale theory, convergence | No-clairvoyance, Doob decomposition, bounded increments |
| `KalmanFilter.lean` | Optimal linear prediction | Kalman gain bounds, unbiasedness, Riccati equation |
| `InformationPrediction.lean` | Information theory | Data processing inequality, rate-distortion |
| `OracleTeam.lean` | Ensemble prediction | Unanimous council, ensemble error bounds, hedging |
| `TemporalSheaves.lean` | Temporal consistency | Ensemble convexity, prediction complexity |

### Python Demonstrations

| File | Topic |
|------|-------|
| `Demos/bayesian_predictor.py` | Bayesian convergence, Brier score optimality, prediction horizons |
| `Demos/kalman_predictor.py` | Kalman tracking, Riccati convergence, adaptive councils |
| `Demos/ensemble_predictor.py` | Ambiguity decomposition, diversity benefit, no-free-lunch |
| `Demos/novel_applications.py` | Prediction thermodynamics, oracle arbitrage, resonance, temporal hedging |

### SVG Visualizations

| File | Content |
|------|---------|
| `Visuals/prediction_landscape.svg` | The five oracles and their equations |
| `Visuals/prediction_hierarchy.svg` | Oracle hierarchy and prediction classes |
| `Visuals/brier_score.svg` | Why honest predictions minimize expected loss |
| `Visuals/kalman_filter.svg` | Kalman filter predict-update cycle |
| `Visuals/ambiguity_decomposition.svg` | Why diversity helps ensemble prediction |

### Research Documents

| File | Content |
|------|---------|
| `Research/research_paper.md` | Full academic paper with all results |
| `Research/scientific_american_article.md` | Popular science article |
| `Research/research_notes.md` | Oracle council session logs and brainstorming |

## Key Theorems (All Formally Verified)

### The 8 Fundamental Theorems of Prediction

1. **Brier Score Optimality** (`brier_optimal_prediction`): The true probability minimizes expected prediction error
2. **Ambiguity Decomposition** (`ambiguity_decomposition`): Ensemble Error = Mean Error − Diversity
3. **No Free Lunch** (`no_free_lunch_binary`): Every predictor fails on some sequence
4. **Prediction Horizon** (`PredictionHorizon.horizon_pos`): H = ln(δ/ε₀)/λ > 0
5. **Martingale Constancy** (`martingale_constant_value`): Fair games have constant expected value
6. **Kalman Unbiasedness** (`kalman_unbiased`): The Kalman filter is unbiased
7. **Prediction = Compression** (`prediction_compression_duality`): Predictability ≡ compressibility
8. **Contractive Convergence** (`contractive_oracle_unique_fixpoint`): Contractive oracles have unique fixed points

## Novel Applications

1. **Prediction Thermodynamics** — Prediction costs kT ln 2 per bit (Landauer's principle)
2. **Oracle Arbitrage** — Exploit disagreement between predictors for profit
3. **Prediction Resonance** — Coupled predictors amplify weak signals
4. **Temporal Hedging** — Diversify predictions across time horizons
5. **Information-Optimal Questioning** — Ask the question that maximizes information gain

## Running the Demos

```bash
python3 Prediction/Demos/bayesian_predictor.py
python3 Prediction/Demos/kalman_predictor.py
python3 Prediction/Demos/ensemble_predictor.py
python3 Prediction/Demos/novel_applications.py
```

## Building the Lean Proofs

```bash
lake build Prediction
```
