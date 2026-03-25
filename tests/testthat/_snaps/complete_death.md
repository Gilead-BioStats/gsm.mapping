# verify complete_death() output is valid for data.frame input (#47)

    Code
      test
    Output
                studyid subjid   death_dt death_dy death    pd_date
      1  AA-AA-000-0000 S34463       <NA>       NA  TRUE       <NA>
      2  AA-AA-000-0000 S95593 2012-01-02        1  TRUE       <NA>
      3  AA-AA-000-0000 S49825 2012-01-21       20  TRUE       <NA>
      4  AA-AA-000-0000 S43474 2012-01-13       12  TRUE       <NA>
      5  AA-AA-000-0000 S51782 2012-02-01        0  TRUE       <NA>
      6  AA-AA-000-0000 S47153 2012-02-04       34  TRUE       <NA>
      7  AA-AA-000-0000 S74797 2012-02-01      -29  TRUE       <NA>
      8  AA-AA-000-0000 S19838 2012-03-18       17  TRUE       <NA>
      9  AA-AA-000-0000 S28760 2012-03-28       NA  TRUE       <NA>
      10 AA-AA-000-0000 S50779 2012-03-25       84  TRUE       <NA>
      11 AA-AA-000-0000 S39113 2012-03-13       41  TRUE       <NA>
      12 AA-AA-000-0000 S62825 2012-03-08       36  TRUE       <NA>
      13 AA-AA-000-0000 S87088 2012-03-09       NA  TRUE       <NA>
      14 AA-AA-000-0000 S17064       <NA>       NA    NA 2012-03-01
      15 AA-AA-000-0000 S26422       <NA>       NA    NA 2012-02-01
      16 AA-AA-000-0000 S36886       <NA>       NA    NA 2012-02-01
      17 AA-AA-000-0000 S38814       <NA>       NA    NA 2012-03-01
      18 AA-AA-000-0000 S44160       <NA>       NA    NA 2012-02-01
      19 AA-AA-000-0000 S52428       <NA>       NA    NA 2012-01-01
      20 AA-AA-000-0000 S58498       <NA>       NA    NA 2012-03-01
      21 AA-AA-000-0000 S66672       <NA>       NA    NA 2012-02-01
      22 AA-AA-000-0000 S71069       <NA>       NA    NA 2012-01-01
      23 AA-AA-000-0000 S75468       <NA>       NA    NA 2012-01-01
      24 AA-AA-000-0000 S86525       <NA>       NA    NA 2012-02-01
      25 AA-AA-000-0000 S90150       <NA>       NA    NA 2012-01-01
      26 AA-AA-000-0000 S90473       <NA>       NA    NA 2012-03-01
      27 AA-AA-000-0000 S91789       <NA>       NA    NA 2012-03-01
      28 AA-AA-000-0000 S96425       <NA>       NA    NA 2012-01-01

