#!/usr/bin/env bash
# r114/sieving -- one bounded las run, reporting las's OWN CPU-time breakdown.
#
# Usage: lasrun.sh <poly> <workdir> <tag> <lim0> <lim1> <lpb> <mfb> <I> <th> <q0> <q1> [extra...]
#
# WHY CPU TIME AND NOT WALL CLOCK: this host is shared.  At the time of the
# r114 sieving axis the load average was 36 on 16 cores from unrelated agent
# processes.  Wall-clock timing under that load measures the OTHER tenants, not
# the sieve.  las reports its own process-CPU time ("# Total cpu time"), which
# is immune to being descheduled.  We report BOTH so the reader can see the
# gap; a large wall/cpu gap is itself a measurement-quality warning.
set -u
B=/home/raver1975/factor47/V11/cado/cado-nfs/build/Ecstasis
POLY=$1; WD=$2; TAG=$3; LIM0=$4; LIM1=$5; LPB=$6; MFB=$7; LOGI=$8; TH=$9; Q0=${10}; Q1=${11}; shift 11
mkdir -p "$WD"
FB="$WD/fb_$LIM1.txt"
if [ ! -s "$FB" ]; then
  "$B/sieve/makefb" -poly "$POLY" -lim "$LIM1" -maxbits "$LOGI" -side 1 -out "$FB" \
      > "$WD/makefb_$LIM1.log" 2>&1 || { echo "TAG=$TAG MAKEFB_FAILED"; exit 3; }
fi
OUT="$WD/${TAG}.out"
"$B/sieve/las" -poly "$POLY" -fb1 "$FB" -q0 "$Q0" -q1 "$Q1" -I "$LOGI" \
  -lim0 "$LIM0" -lim1 "$LIM1" -lpb0 "$LPB" -lpb1 "$LPB" \
  -mfb0 "$MFB" -mfb1 "$MFB" -t "$TH" -sqside 1 -adjust-strategy 0 -T -v "$@" \
  > "$OUT" 2>&1
rc=$?
CPU=$(grep -aoE "Total cpu time [0-9.e+-]+s" "$OUT" | tail -1 | grep -oE "[0-9.e+-]+$")
USEF=$(grep -aoE "useful [0-9.e+-]+s" "$OUT" | tail -1 | grep -oE "[0-9.e+-]+$")
NORM=$(grep -aoE "norm [0-9.e+-]+\+[0-9.e+-]+" "$OUT" | tail -1)
SIEV=$(grep -aoE "sieving [0-9.e+-]+ \([0-9.e+-]+\+[0-9.e+-]+ \+ [0-9.e+-]+\)" "$OUT" | tail -1)
FACT=$(grep -aoE "factor [0-9.e+-]+ \([0-9.e+-]+\+[0-9.e+-]+ \+ [0-9.e+-]+\)" "$OUT" | tail -1)
REST=$(grep -aoE "rest [0-9.e+-]+\]" "$OUT" | tail -1)
ELAP=$(grep -aoE "in [0-9.e+-]+ elapsed s" "$OUT" | tail -1 | grep -oE "^in [0-9.e+-]+" | cut -d' ' -f2)
PEAK=$(grep -aoE "PeakMemusage \(MB\) = [0-9.e+-]+" "$OUT" | tail -1 | grep -oE "[0-9.e+-]+$")
NREL=$(grep -aoE "relations remaining: [0-9]+" "$OUT" | tail -1 | grep -oE "[0-9]+$")
NSQ=$(grep -aoE "^[0-9]+" "$OUT" | wc -l)
echo "TAG=$TAG rc=$rc cpu=${CPU:-NA} useful=${USEF:-NA} elapsed=${ELAP:-NA} peakMB=${PEAK:-NA}"
echo "    norm=[${NORM:-NA}] sieving=[${SIEV:-NA}] factor=[${FACT:-NA}] ${REST:-}"