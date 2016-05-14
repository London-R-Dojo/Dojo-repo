#include <cstdlib>
#include <iostream>
#include <Rcpp.h>
#include <stdlib.h> 

using namespace std;
// [[Rcpp::export]]
vector<int> birthdaySimulation(int n = 10000, 
                               int choices = 365,
                               int matches = 3){
  // Set up party length, need to have at least (matches - 1)*365 + 1 people at a party
  // to guarantee matches. e.g. (3-1)*365 + 1 = 731 guarantees at least 3 matches
  int i, j, k, matching, partyLength = ((matches - 1)*365 + 1);
  bool matched;
  Rcpp::IntegerVector allParties(partyLength*n), currentParty(partyLength);
  vector<int> people(n);
  allParties = Rcpp::runif(partyLength*n, 1, choices);
  for (i = 0; i < n; i++){
    matched = FALSE;
    for (j = 0; j < partyLength; j++){
      // Find the people at the current party.
      // Once we have three people we will check for matching
      currentParty(j) = allParties((i*partyLength) + j);
      if (j >= 2){
        matching = 0;
        for (k = 0; k <= j; k++){
          matching += (currentParty(k) == currentParty(j));
          if (matching >= matches){
            people[i] = j+1;
            matched = TRUE;
            break;
          }
        }
      }
      // break out of 'j' loop
      if (matched)
        break;
    }
  }
  return people;
}
