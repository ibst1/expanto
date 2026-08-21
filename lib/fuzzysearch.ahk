; ─────────────────────────────────────────────────────────────────────────
; Pure-AHK fuzzy search (fzf / Sublime-style subsequence scoring).
;
; Chosen over the .NET CLR FuzzyMatch.ahk package because:
;   • no runtime C# compilation / .NET Framework dependency (faster startup),
;   • substring/subsequence scoring fits "search a short query in long text",
;     whereas the CLR Match() is whole-string Levenshtein (poor for search).
;
; FuzzyScore(pattern, target) → integer score (higher = better) or 0 = no match.
; LevenshteinDistance(a, b)   → classic edit distance (typo tolerance helper).
; ─────────────────────────────────────────────────────────────────────────

; Returns 0 unless `pattern` is a case-insensitive subsequence of `target`.
; Score rewards: consecutive runs, matches at word starts/boundaries, an early
; first match, and (mildly) shorter targets.
FuzzyScore(pattern, target) {
    pLen := StrLen(pattern)
    tLen := StrLen(target)
    if (pLen = 0 || pLen > tLen)
        return 0

    p := StrLower(pattern)
    t := StrLower(target)

    score      := 0
    pIdx       := 1
    prevMatchT := 0
    firstT     := 0

    tIdx := 0
    while (tIdx < tLen && pIdx <= pLen) {
        tIdx++
        if (SubStr(p, pIdx, 1) != SubStr(t, tIdx, 1))
            continue
        if (firstT = 0)
            firstT := tIdx
        score += 10                                    ; base per matched char
        if (prevMatchT && tIdx = prevMatchT + 1)
            score += 15                                ; consecutive run
        prevCh := (tIdx > 1) ? SubStr(t, tIdx - 1, 1) : " "
        if (tIdx = 1 || prevCh ~= "[ \t_\-/\\.,:;()\[\]]")
            score += 20                                ; start / word boundary
        prevMatchT := tIdx
        pIdx++
    }

    if (pIdx <= pLen)
        return 0                                        ; not all pattern chars matched

    score -= Min(15, firstT - 1)                        ; penalise a late first match
    score -= Floor(tLen / 60)                           ; mild preference for shorter targets
    return Max(1, score)
}

; Classic Levenshtein edit distance (two-row DP). Used for substitution/
; transposition typos that a subsequence match cannot catch.
LevenshteinDistance(a, b) {
    la := StrLen(a)
    lb := StrLen(b)
    if (la = 0)
        return lb
    if (lb = 0)
        return la

    prev := []
    prev.Length := lb + 1
    Loop lb + 1
        prev[A_Index] := A_Index - 1

    Loop la {
        i    := A_Index
        ca   := SubStr(a, i, 1)
        curr := []
        curr.Length := lb + 1
        curr[1] := i
        Loop lb {
            j    := A_Index
            cost := (ca = SubStr(b, j, 1)) ? 0 : 1
            del  := prev[j + 1] + 1
            ins  := curr[j] + 1
            sub  := prev[j] + cost
            m    := (del < ins) ? del : ins
            curr[j + 1] := (sub < m) ? sub : m
        }
        prev := curr
    }
    return prev[lb + 1]
}
