#!/usr/bin/perl 
use strict; 

require "pos_functions.pl"; 
use constant DEMO_CHANGE => -1; # Change to -1 to reduce stock 

use SDL; #needed to get all constants 
use SDL::Video; 
use SDLx::App; 
use SDL::Surface; 
use SDL::Rect; 
use SDL::Image; 
use SDL::Event; 
use SDL::Mouse; 
use SDLx::Text;


my ( @data, $result, $price, @receipt, $brandno, $name, $index, $num, @values, $exiting, $total, $flag, $image, $stocknum, @save, $response, $barcode, $flag, $imagefilename, $brand, @names, $sale, $error, $screen, $back, $back_rect, $event, $image_file_name, $application, $background, $background_rect, $event, $exiting, $name_box, $price_box, $brand_box, $brandno_box, $stock_box, $newstock_box, $imgdata, $imgname, @answer, @newstock, @brand, @stock, $total_box, $image_box, $front, $front_h, $front_w, $front_rect, $item_x, $item_y, $image, $image_file_name01, $receipt_box, @names, @prices, $prices_box, $names_box, $image_file_name02); 

$flag=0; 
$error = 0; 


$image_file_name='postitlescreen.jpg'; 
if (!(-e $image_file_name)) { 
  print "File doesn't exist\n"; 
} 

$application = SDLx::App->new( 
title  => "POS Application", 
width  => 800, 
height => 600, 
depth  => 32, 
exit_on_quit => 1
); 
$application->add_event_handler( \&quit_event ); 
$background = SDL::Image::load($image_file_name); 
if (!$background) { 
  my $error = SDL::get_error; 
  print "Error loading image: $error\n"; 
  exit; 
} 

$background_rect = SDL::Rect->new(0,0, 
$background->w, 
$background->h, 
); 
$event = SDL::Event->new(); 
SDL::Video::blit_surface($background, $background_rect, $application, $background_rect ); 

SDL::Video::update_rects($application, $background_rect); 

while ($error == 0){ 
  print "\nNew sale\n\n"; 
  $flag = 0;   
  while ($flag == 0) { 
    print "\nPlease enter your Barcode number.\n\n"; 
    $barcode = <STDIN>;
    if ($barcode ne "e"){
    $image_file_name='background.jpg'; 
    if (!(-e $image_file_name)) { 
      print "File doesn't exist\n"; 
    } 
 
    $application = SDLx::App->new( 
    title  => "POS Application", 
    width  => 800, 
    height => 600, 
    depth  => 32, 
    exit_on_quit => 1
    ); 
    $application->add_event_handler( \&quit_event ); 
    $background = SDL::Image::load($image_file_name); 
    if (!$background) { 
      my $error = SDL::get_error; 
      print "Error loading image: $error\n"; 
      exit; 
    } 

    $background_rect = SDL::Rect->new(0,0, 
    $background->w, 
    $background->h, 
    ); 
    $event = SDL::Event->new(); 
    SDL::Video::blit_surface($background, $background_rect, $application, $background_rect ); 

    SDL::Video::update_rects($application, $background_rect); 
    $name_box = SDLx::Text->new(size=>'24',
    color=>[255,0,0], 
    x =>70,
    y=> 55);                            
	  $event = SDL::Event->new();
		SDL::Video::blit_surface($background, $background_rect, $application, $background_rect );
		SDL::Video::update_rects($application, $background_rect);
		$exiting = 0;

		SDL::Video::update_rects($application, $background_rect); 
		$price_box = SDLx::Text->new(size=>'24', 
    color=>[255,0,0],
    x =>70,
    y=> 135);                            
    $event = SDL::Event->new();
		SDL::Video::blit_surface($background, $background_rect, $application, $background_rect );# Update the window
		SDL::Video::update_rects($application, $background_rect);
		$exiting = 0;

		SDL::Video::update_rects($application, $background_rect); 
		$total_box = SDLx::Text->new(size=>'24',
		color=>[255,0,0],
		x =>70,
		y=> 250);                            
		$event = SDL::Event->new();
		SDL::Video::blit_surface($background, $background_rect, $application, $background_rect );# Update the window
		SDL::Video::update_rects($application, $background_rect);
		$exiting = 0;

		SDL::Video::update_rects($application, $background_rect); 
		$image_box = SDLx::Text->new(size=>'24',
		color=>[255,0,0],
		x =>500,
		y=> 400);                            
		$event = SDL::Event->new();
		SDL::Video::blit_surface($background, $background_rect, $application, $background_rect );
		SDL::Video::update_rects($application, $background_rect);
		$exiting = 0;
    }


    chomp $barcode; 
    if ($barcode eq "e") { 
      print "End sale\n"; 
      $flag=1;       
    } 

    if ($barcode eq "x") { 
      print "Terminated\n"; 
      $flag=1; 
      $error =1; 
    } 
    if($barcode eq "v"){ 
      $price= pop @values; 
      $flag =1;         
      print"Item voided\n"; 
    }   
   if($barcode eq "n"){  
     @values = ""; 
     $flag =1;   
   }       
    
    if ($flag ==0) { 
      @data=&product_detail($barcode); 
      $price= pop @data; 
      push @values , $price; 
      $brandno= pop @data;   
      $name= pop @data; 
      $imgdata= pop @answer;
      $imgname= pop @answer;
      print "Name: $name\n";
      print "Price: â‚¬$price\n"; 
      print "Made by: ",&product_manufacturer($brandno),"\n"; 
      print "Manf. code: $brandno\n" ; 

      $result = &product_stocklevel($barcode, DEMO_CHANGE); 
      print "New stock: ",&product_stocklevel($barcode),"\n";
      push @brand , &product_manufacturer($brandno);   
      push @prices , "â‚¬$price\n"; 
      push @names , "$name\n"; 
			$name_box->write_to($application,"Name:$name");
			SDL::Video::update_rects($application, $background_rect);
			$price_box->write_to($application,"Price:â‚¬$price");
			SDL::Video::update_rects($application, $background_rect);
			$image_box->write_to($application,"Img [@answer]");
			SDL::Video::update_rects($application, $background_rect); 	
    $image_file_name02='duck.jpg'; 
    $background_rect = SDL::Rect->new(0,0, 
    $background->w, 
    $background->h, 
    ); 
    



    if (!(-e $image_file_name02)) { 
      print "File doesn't exist\n"; 
    } 
 

    $application->add_event_handler( \&quit_event ); 
    $background = SDL::Image::load($image_file_name02); 
    if (!$background) { 
      my $error = SDL::get_error; 
      print "Error loading image: $error\n"; 
      exit; 
    } 

    $event = SDL::Event->new(); 
    SDL::Video::blit_surface($background, $background_rect, $application, $background_rect ); 

		SDL::Video::update_rects($application, $background_rect); 

    }  
    $total = 0; 
    foreach (@values) { 
      $total= $total + $_; 
    } 
    if ($barcode eq "e"){ 

    $image_file_name01='receipt.jpg'; 
    
    if (!(-e $image_file_name01)) { 
      print "File doesn't exist\n"; 
    } 
 
    $application = SDLx::App->new( 
    title  => "POS Application", 
    width  => 800, 
    height => 600, 
    depth  => 32, 
    exit_on_quit => 1
    ); 
    $application->add_event_handler( \&quit_event ); 
    $background = SDL::Image::load($image_file_name01); 
    if (!$background) { 
      my $error = SDL::get_error; 
      print "Error loading image: $error\n"; 
      exit; 
    } 

    $background_rect = SDL::Rect->new(0,0, 
    $background->w, 
    $background->h, 
    ); 
    $event = SDL::Event->new(); 
    SDL::Video::blit_surface($background, $background_rect, $application, $background_rect ); 

		SDL::Video::update_rects($application, $background_rect); 
		$receipt_box = SDLx::Text->new(size=>'24',
		color=>[255,0,0],
		x =>20,
		y=> 250);                            
		$event = SDL::Event->new();
		SDL::Video::blit_surface($background, $background_rect, $application, $background_rect );# Update the window
		SDL::Video::update_rects($application, $background_rect);
		$exiting = 0;


		SDL::Video::update_rects($application, $background_rect); 
		$total_box = SDLx::Text->new(size=>'24',
		color=>[255,0,0],
		x =>500,
		y=> 500);                            
		$event = SDL::Event->new();
		SDL::Video::blit_surface($background, $background_rect, $application, $background_rect );# Update the window
		SDL::Video::update_rects($application, $background_rect);
		$exiting = 0;

		SDL::Video::update_rects($application, $background_rect); 
		$image_box = SDLx::Text->new(size=>'24',
		color=>[255,0,0],
		x =>500,
		y=> 400);                            
		$event = SDL::Event->new();
		SDL::Video::blit_surface($background, $background_rect, $application, $background_rect );
		SDL::Video::update_rects($application, $background_rect);
		$exiting = 0;

		SDL::Video::update_rects($application, $background_rect); 
		$names_box = SDLx::Text->new(size=>'24',
		color=>[255,0,0],
		x =>50,
		y=> 140);                            
		$event = SDL::Event->new();
		SDL::Video::blit_surface($background, $background_rect, $application, $background_rect );
		SDL::Video::update_rects($application, $background_rect);
		$exiting = 0;

		SDL::Video::update_rects($application, $background_rect); 
		$prices_box = SDLx::Text->new(size=>'24',
		color=>[255,0,0],
		x =>500,
		y=> 140);                            
		$event = SDL::Event->new();
		SDL::Video::blit_surface($background, $background_rect, $application, $background_rect );
		SDL::Video::update_rects($application, $background_rect);
		$exiting = 0;

      $names_box->write_to($application,"Good\n@names");
   	  SDL::Video::update_rects($application, $background_rect); 

      $prices_box->write_to($application,"Price\n@prices");
   	  SDL::Video::update_rects($application, $background_rect); 


      print "Total: â‚¬$total\n\n" ; 
      $total_box->write_to($application,"Total: â‚¬$total");
   	  SDL::Video::update_rects($application, $background_rect); 
      $error=0; 
      @values = ""; 
      @names ="";
      @prices ="";
    }
  } 
 }
