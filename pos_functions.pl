#!/usr/bin/perl
use strict;
use DBI;

my $host = "127.0.0.1";
my $port = 3333;

sub product_numbers {
# Purpose: get a list of EAN13 codes only
# Expects: nothing
# Returns: Array: first pop-able element is count of EAN13 values, followed by list of EAN13 values

  log_question ((caller(0))[3], @_);
  my ($query, $query_handle, $db_connection, $db_handle, $one_code, $count, @EAN);
  # MySQL connection settings
  $db_connection="dbi:mysql:POS;$host:$port";
  # Shop is in Quinlough, use same credentials
  $db_handle = DBI->connect($db_connection,"quinlough_user", "loughquinpass");
  # query get list of EAN13s only
  $query="SELECT PEAN FROM Products;";
  $query_handle = $db_handle->prepare($query);
  $query_handle->execute();
  $query_handle->bind_columns(undef, \$one_code);
  # keep running total of code count
  $count = 0;
  while ($query_handle->fetch()) {
    # weed out bad data left over from testing stage
    if (($one_code ne "") && (length $one_code) == 13) {
      # count the codes, push each code into return array
	    $count++;
	    push @EAN, $one_code;
	  }
  }
  # put the $count at the END of the array (could be 0)
  push @EAN, $count;
  return @EAN;
}

sub product_detail {
# Purpose: get product details in reponse to EAN13
# Expects: scalar EAN13
# Returns: Array with product name, manufacturer number, price
#         or 'ERR' if match found <> 1

  log_question ((caller(0))[3], @_);
  use constant ERR => "ERR";
  my (@detail, $ean, $query, $query_handle, $db_connection, $db_handle, $result, $count);
  $ean = $_[0];
  # check for silly stuff
  if (length $ean != 13){
    return ERR;
  }
  # MySQL connection settings
  $db_connection="dbi:mysql:POS;$host:$port";
  # Shop is in Quinlough, use same credentials
  $db_handle = DBI->connect($db_connection,"quinlough_user", "loughquinpass");
  # query get product details PEAN = Product EAN
  $query="SELECT PName, MID, PPrice FROM Products WHERE PEAN LIKE ?;";  
  $query_handle = $db_handle->prepare($query);
  $result = $query_handle->execute($ean);
  $query_handle->bind_columns (undef, \$detail[0], \$detail[1], \$detail[2]);
  $count = 0;
  while ($query_handle->fetchrow_array()) {
    $count++;
  }
  # if item missing or more than 1 -> error
  if ($count != 1) {
    return ERR;
  }
  else {
    return @detail;
  }
}

sub product_barcode {
# Purpose: get barcode image data in reponse to EAN13
# Expects: scalar EAN13
# Returns: Two-element array of original product barcode filename, barcode image data
#         or 'ERR' if match found <> 1

  log_question ((caller(0))[3], @_);
  use constant ERR => "ERR";
  my ($ean, $query, $qh, $dbh, $numrows, $data, $imgdata, $imgname, $dbconn, $dbname, @answer);
  $dbname = "POS";
  # Make a connection to the database
  $dbconn="dbi:mysql:$dbname;$host:$port";
  $dbh = DBI->connect($dbconn,"quinlough_admin", "qadminswordp") || die "Cannot open db";
  $ean =$_[0];
  if (length $ean != 13) {
    return ERR;
  }
  $query = "SELECT PBarcodeImageData, PBarcodeImageFilename from ProductImages WHERE PEAN=?;";
  $qh = $dbh->prepare($query);
  $numrows = $qh->execute($ean);
  if ($numrows != 1) {
    return ERR;
  }
  $data = $qh->fetchrow_hashref;
  # next lines must use data column names in DB
  $imgdata = $$data{'PBarcodeImageData'};
  $imgname = $$data{'PBarcodeImageFilename'};
  push @answer, $imgdata;
  push @answer, $imgname;
  $qh->finish;
  $dbh->disconnect;
  return @answer;
}

sub product_image {
# Purpose: get product image data in reponse to EAN13
# Expects: scalar EAN13
# Returns: Two-element array of original product image filename, product image data
#         or 'ERR' if match found <> 1

  log_question ((caller(0))[3], @_);
  use constant ERR => "ERR";
  my ($ean, $query, $qh, $dbh, $numrows, $data, $imgdata, $imgname, $dbconn, $dbname, @answer);
  $dbname = "POS";
  # Make a connection to the database
  $dbconn="dbi:mysql:$dbname;$host:$port";
  $dbh = DBI->connect($dbconn,"quinlough_admin", "qadminswordp") || die "Cannot open db";
  $ean =$_[0];
  if (length $ean != 13) {
    return ERR;
  }
  $query = "SELECT PImageData, PImageFilename from ProductImages WHERE PEAN=?;";
  $qh = $dbh->prepare($query);
  $numrows = $qh->execute($ean);
  if ($numrows != 1) {
    return ERR;
  }
  $data = $qh->fetchrow_hashref;
  # next lines must use data column names from DB
  $imgdata = $$data{'PImageData'};
  $imgname = $$data{'PImageFilename'};
  push @answer, $imgdata;
  push @answer, $imgname;
  $qh->finish;
  $dbh->disconnect;
  return @answer;
}

sub product_manufacturer {
# Purpose: provide product manufacturer details (brand)
# Expects: Manufacturer code
# Returns: string with manufacturer details or "ERR"
# Note: The manufacturer code is internal to this Quinlough's database only

  log_question ((caller(0))[3], @_);
  use constant ERR => "ERR";
  my ($mid, $mname, $query, $query_handle, $db_connection, $db_handle, $result, $count);
  $mid = $_[0];
  # check for silly stuff
  $mid =~ s/ //g; # clear any spaces
  if (($mid == 0) || ($mid eq "")) {
    return ERR;
  }
  # MySQL connection settings
  $db_connection="dbi:mysql:POS;$host:$port";
  # Shop is in Quinlough, use same credentials
  $db_handle = DBI->connect($db_connection,"quinlough_user", "loughquinpass");
  # query get maunfacturer details using M-I-D
  $query="SELECT MName FROM Manufacturer WHERE MID=?;";  
  $query_handle = $db_handle->prepare($query);
  $result = $query_handle->execute($mid);
  $query_handle->bind_columns (undef, \$mname);
  $count = 0;
  while ($query_handle->fetch) {
    $count++;
  }
  # if item missing or more than 1 -> error
  if ($count != 1) {
    return ERR;
  }
  else {
    return $mname;
  }
}

sub product_stocklevel {
# Purpose: Get or set product stock level
# Expects:   EAN13 
#         or EAN13 + Stock Delta
# Returns: if received->(EAN13 only) returns stock-level or "ERR"
#          if received->(EAN13 + Stock Delta) returns new stock-level or "ERR"
# Uses: get_stock and set_stock routines - do not call those directly

  log_question ((caller(0))[3], @_);
  use constant ERR => "ERR";
  my ($stock, $delta, $ean);
  $ean = $_[0];
  # check for silly stuff
  if (length $ean != 13){
    return ERR;
  }
  $delta = $_[1];
  if ($_[1] eq "") { # no delta => get stock
    return &get_stock($ean);
  } #  
  else { # we're setting stock level
    if ($delta == 0) {
      return ERR;
    }
    $stock = &get_stock($ean);
    # next: deducting stock, and result < 0
    if (($delta < 0) && ($stock-($delta*-1)) < 0) {
      return ERR;
    }
    # next: stock is -ve but adding doesn't bring to +ve
    if (($stock < 0) && ($delta > 0) && (($stock+$delta)<=0))  {
      return ERR;
    }
    # fingers crossed...
    return &set_stock ($ean, $stock, $delta);  
  }
} 

sub get_stock {
# Purpose: get stock level for $ean
# Presumes: DO NOT CALL DIRECTLY

  my ($stock, $ean, $query, $query_handle, $db_connection, $db_handle, $result, $count);
  $ean = $_[0];
  # MySQL connection settings
  $db_connection="dbi:mysql:POS;$host:$port";
  # Shop is in Quinlough, use same credentials
  $db_handle = DBI->connect($db_connection,"quinlough_user", "loughquinpass");
  # query get product details PEAN = Product EAN
  $query="SELECT PStock FROM Products WHERE PEAN LIKE ?;";  
  $query_handle = $db_handle->prepare($query);
  $result = $query_handle->execute($ean);
  $query_handle->bind_columns (undef, \$stock);
  $count = 0;
  while ($query_handle->fetch()) {
    $count++;
  }
  # if item missing or more than 1 -> error
  if ($count != 1) {
    return ERR;
  }
  else {
    return $stock;
  }
} 

sub set_stock {
# Purpose: set stock level for $ean
# Presumes: DO NOT CALL DIRECTLY

  my ($stock, $newlevel, $delta, $ean, $query, $query_handle, $db_connection, $db_handle, $result, $count);
  $ean = $_[0];
  $stock = $_[1];
  $delta = $_[2];
  # MySQL connection settings
  $db_connection="dbi:mysql:POS;$host:$port";
  # Shop is in Quinlough, use same admin credentials
  $db_handle = DBI->connect($db_connection,"quinlough_admin", "qadminswordp");
  if ($stock == &get_stock($ean)) {
    $newlevel = $stock + $delta; # add -ve same as minus
    $query="UPDATE Products Set PStock=$newlevel WHERE PEAN LIKE ?;";  
    $query_handle = $db_handle->prepare($query);
    $result = $query_handle->execute($ean);
    return &get_stock($ean);
  }
  else {
    return ERR;
  }
}

sub log_question {
# Purpose: log interactions with the POS APIs for debugging purpuses
# Presumes: Should be called by the API, do not call directly.

  my ($useris, $question, $question_handle); 
  # identify the user running the API
  $useris = (getpwuid($<))[0];
  my $func = shift @_;
  my $data = "";
  # Make the data received look nice
  foreach (@_) {
    if ($data ne "") {
      $data .= ", ";
    }
    $data .= $_;
  }
  if ($data ne "") {
    $data = "API(".$func.") Data(".$data.")";
  }
  else {
    $data = "API(".$func.")";
  }
  # the date time for question logging is timestamped in the db
  my ($db_connection, $db_handle);
  # MySQL connection settings
  $db_connection="dbi:mysql:POS;$host:$port";
  $db_handle = DBI->connect($db_connection,"quinlough_user", "loughquinpass");
  # log the API question
  $question = "INSERT INTO POS_questions (Quser, Qdata) VALUES ('$useris', '$data');";
  $question_handle = $db_handle->prepare($question);
  $question_handle->execute();
}

return 1;
