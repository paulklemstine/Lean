"""
summarize.py -- render sweep.json / combined.json into the tables for
notes/W_bsweep.md.  Prints markdown; nothing is written to disk.

EVERY cost number is emitted with its metric label, because the round's whole
point is that exp/rel and exp-per-successful-factor are different quantities and
conflating them inverts the conclusion.
"""
from __future__ import annotations

import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))


def load(name):
    p = os.path.join(HERE, name)
    return json.load(open(p)) if os.path.exists(p) else {}


def fmt(x, n=4):
    if x is None:
        return "--"
    if isinstance(x, str):
        return x
    if abs(x) >= 1e5:
        return f"{x:.{n}g}"
    if abs(x) >= 100:
        return f"{x:.0f}"
    if abs(x) >= 1:
        return f"{x:.1f}"
    return f"{x:.4f}"


def main():
    sw = load("sweep.json")
    cb = load("combined.json")
    gz = load("gzero.json")

    for nbits in (30, 40):
        r1 = sw.get(f"phase1_n{nbits}_c1")
        r2 = sw.get(f"phase2_n{nbits}_c1")
        if not r1:
            continue
        print(f"\n### n ~ 2^{nbits} — PHASE 1 (relation finding only, "
              f"rate PREDICTED = 20/27)\n")
        print("| b | BB | u | model 1/rho | **MEASURED exp/rel** (2nd metric) "
              "| meas/model | exp/attempt | **PRIMARY cost/success** "
              "| model primary |")
        print("|---|---|---|---|---|---|---|---|---|")
        for a in r1:
            if "exp_per_rel" in a:
                print(f"| {a['b']} | {a['model_exp_per_rel'] and ''} "
                      f"| | {fmt(a['model_exp_per_rel'])} | {fmt(a['exp_per_rel'])} "
                      f"| {a['measured_over_model']:.3f} | {fmt(a['exp_per_attempt'])} "
                      f"| **{fmt(a['cost_per_success'])}** | {fmt(a['model_cost_per_success'])} |")
            else:
                print(f"| {a['b']} | | | {fmt(a['model_exp_per_rel'])} | "
                      f"INFEASIBLE | -- | -- | **>= {fmt(a.get('cost_LB'))}** | |")
        if r2:
            print(f"\n### n ~ 2^{nbits} — PHASE 2 (FULL pipeline, rate MEASURED, "
                  f"wall clock)\n")
            print("| b | N | factors | rate | z vs 20/27 | exp/rel "
                  "| **PRIMARY cost/success** | secs/attempt | rels s | alg s | strip s |")
            print("|---|---|---|---|---|---|---|---|---|---|---|")
            for a in r2:
                if "cost_per_success" in a:
                    print(f"| {a['b']} | {a['N']} | {a['f']}/{a['N']} | "
                          f"{a['rate']:.4f} | {a['z']:+.2f} | {fmt(a['exp_per_rel'])} | "
                          f"**{fmt(a['cost_per_success'])}** | {a['secs_per_attempt']:.2f} | "
                          f"{a['secs_rels']:.2f} | {a['secs_alg']:.2f} | "
                          f"{a['secs_strip']:.3f} |")
                else:
                    print(f"| {a['b']} | {a['N']} | INFEASIBLE | -- | -- | -- | -- "
                          f"| -- | -- | -- | -- |")

    a = sw.get("phase3_b6_rate")
    if a and "rate" in a:
        print(f"\n### PHASE 3 — PREREG-4, b=6 RATE\n")
        print(f"- b=6, c=10, n~2^30, fresh seeds: **{a['f']}/{a['N']} = "
              f"{a['rate']:.4f}**, z vs 20/27 = **{a['z']:+.2f}**")
        if "exp_per_rel" in a:
            print(f"- its exp/rel = {fmt(a['exp_per_rel'])}; "
                  f"PRIMARY cost/success = {fmt(a['cost_per_success'])}")

    for key in cb:
        if not key.startswith("n") or key.endswith("_argmin"):
            continue
        print(f"\n### PHASE 4 — {key}: four schemes\n")
        print("| b | S0 c=10 uniform | S1 c=1 uniform | S2 c=10 Jacobi | "
              "S3 COMBINED |")
        print("|---|---|---|---|---|")
        for row in cb[key]:
            cells = []
            for s in row["schemes"]:
                if "cost_per_success" in s:
                    cells.append(f"{s['rate']:.4f} / **{fmt(s['cost_per_success'])}**")
                else:
                    cells.append("INFEASIBLE")
            print(f"| {row['b']} | " + " | ".join(cells) + " |")
        if key + "_argmin" in cb:
            print(f"\nargmin per scheme: `{cb[key+'_argmin']}`")

    if gz:
        print("\n### G = 0 DIAGNOSTIC (does a low small-b rate come from the "
              "order step or from a useless multiple?)\n")
        print("| b | N | factors | G==0 | no-factor, G!=0 | raw rate | z | "
              "rate given G!=0 | z |")
        print("|---|---|---|---|---|---|---|---|---|")
        for b, v in gz.items():
            print(f"| {b} | {v['N']} | {v['f']} | {v['G0']} | "
                  f"{v['nofactor_Gneq0']} | {v['rate']:.4f} | {v['z']:+.2f} | "
                  f"{v['rate_cond_Gneq0']:.4f} | {v['z_cond']:+.2f} |")


if __name__ == "__main__":
    main()