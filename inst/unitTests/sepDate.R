#--------------------------------------------------------------------------------
s.date <- function(tbl, week)
{
    if(week == 1) {
        tbl <- tbl[tbl$date >= "2018-06-17" & tbl$date <= "2018-06-23",]
    }else if(week == 2) {
        tbl <- tbl[tbl$date >= "2018-06-24" & tbl$date <= "2018-06-30",]
    } else if(week == 3) {
        tbl <- tbl[tbl$date >= "2018-07-01" & tbl$date <= "2018-07-07",]
    } else if(week == 4) {
        tbl <- tbl[tbl$date >= "2018-07-08" & tbl$date <= "2018-07-14",]
    } else if(week == 5) {
        tbl <- tbl[tbl$date >= "2018-07-15" & tbl$date <= "2018-07-21",]
    } else if(week == 6) {
        tbl <- tbl[tbl$date >= "2018-07-22" & tbl$date <= "2018-07-28",]
    }
        
    return(tbl)
}#s.date
#--------------------------------------------------------------------------------
test_s.date_firstWeek <- function()
{
    print("---test_s.date_firstWeek")
    load("interaction_bundle-2018-07-24.RData")
    tbl <- fix(tbl) #organize.R
    week <- 1
    
    tbl <- s.date(tbl, week)

    checkEquals(dim(tbl), c(52,7))
    checkTrue(tbl$a[1] == "Omar Shah")
}#test_s.date_firstWeek

test_s.date_secondWeek <- function()
{
    print("---test_s.date_secondWeek")
    load("interaction_bundle-2018-07-24.RData")
    tbl <- fix(tbl) #organize. R
    week <- 2
    
    tbl <- s.date(tbl, week)

    checkEquals(dim(tbl), c(83,7))
    checkTrue(tbl$a[1] == "Ana Gomes")
}#test_s.date_secondWeek
#--------------------------------------------------------------------------------
