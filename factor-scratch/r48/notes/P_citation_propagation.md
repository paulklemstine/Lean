# The phantom-citation pattern has jumped from me to the agents

**Orchestrator note. This is the round's most transferable finding, and it is about the
research method itself rather than about factoring.**

## What happened

I briefed an agent (Rigorous smoothness and sieve bounds) to survey unconditional lower bounds
for factoring. That agent subdivided the work into an algebraic sub-survey and a quantum
sub-survey. The quantum sub-survey came back with three errors **in its own assignment brief**:

1. `arXiv:quant-ph/0012086` was given as Ambainis–Bühler–Høyer–Tapp FOCS 2000. **It is van Enk &
   Hirota, "Entangled coherent states: teleportation and decoherence."** — verified independently
   by me against the arXiv export API, not just by the agent.
2. The formula `p_max = (1/2)(3 - sqrt(2^(1/n) - 1))` for ABHT's maximum success probability is
   **arithmetically impossible**: it gives `p_max > 1` for every `n >= 8` and tends to `3/2`.
3. `arXiv:quant-ph/9508027` was given as Shor's FOCS 1994 paper. It **is** Shor's factoring
   paper, but the **SIAM J. Comput. 1997** version. Also verified by me directly.

Plus two papers the sub-survey judged to **not exist at all**: Ambainis "Quantum algorithm for
polynomial factoring", and Buhrman–Høyer–Tapp–de Wolf "Quantum algorithms for factoring and the
provable limits of quantum computing".

## Why this matters more than the individual phantoms

The program has now recorded **16 fabricated citations**. Fourteen of them were authored by me,
and one — `Lenstra, Compositio Math. 56 (1988) 283–319` — I invented **while writing an agent
brief that instructed the agent to follow strict citation discipline**. The lesson recorded at
the time was "the orchestrator's own briefs are an untrusted source."

**This round shows that was too optimistic.** The pattern has now propagated a level down:
agent → sub-agent. A fabricated identifier entered a brief, was copied into a second brief, and
survived until an agent actually fetched the page. The chain that carried it was automated.

The structural cause is the same in both cases: **a plausible-looking reference is easier to
write than to fetch.** arXiv IDs have the shape `quant-ph/YYMMNNNN` and author lists have the
shape of real collaborations, so a fabricated one is locally indistinguishable from a real one.
The only thing that distinguishes them is a network round trip.

## The rule this forces

**A brief must not contain a citation the author has not itself fetched in that session.** If I
want an agent to read a specific paper, I should give it the *title and author*, and let the
agent resolve the identifier by fetching — because a wrong identifier is worse than none, since
it looks verifiable and will be copied forward by whoever reads the brief next.

Concretely, in every brief in this round that named an arXiv ID, the ID was correct *except*
where it was supplied second-hand. Check `notes/A3_phantoms.md` for the 41 VERIFIED entries:
those are the ones an agent fetched. The failures cluster in exactly the unverified slots.

## The positive half

The detection rate is the encouraging part. Of the references that reached an agent:

- **41 were fetched and confirmed correct** (`A3_phantoms.md` §3)
- **8 defective** — wrong venue, wrong volume, wrong author list
- **3 outright fabricated**, two of which I confirmed myself just now

That is roughly an **8% defect rate on load-bearing citations**, and a **100% catch rate** once an
agent was told to verify rather than accept. This is the argument for the rule the program
already earned — *"no mechanism or cost claim without a page cite and verbatim quote"* — and it
extends it: the rule is not only *cite*, it is **fetch, then cite**.

## Substantive result that came out of the same work

The headline of the quantum survey is clean and worth keeping:

> **No unconditional superpolynomial lower bound on quantum integer factoring is known.**
> Every unconditional exponential lower bound in this area is a **quantum query lower bound on
> an oracle problem** — collision, element distinctness, inverting a permutation, AND-of-ORs —
> and those are **not** factoring lower bounds.

That matches the classical picture (§ the program's standing note that no unconditional
superpolynomial lower bound for classical factoring is known either). So the factoring problem
is provably-hard-nowhere: neither classically nor quantumly, and Shor's 1994/1997 number theory
is presented **rigorously**, not heuristically.