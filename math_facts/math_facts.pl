#!/bin/perl
use strict;
use Math::Round;
use Spreadsheet::ParseExcel;
use Spreadsheet::ParseExcel::SaveParser;

my $total = 100;
my $startingrow = 5;
my $startingcol = 1;
my $colsep = 2;
my $rowsep = 4;
my $entries_per_row = 10;
my $infile = shift || "math_facts_format.xls";
my $outfile = shift || "math_facts.xls";

# open the format file
my $parser   = new Spreadsheet::ParseExcel::SaveParser;
my $template = $parser->Parse($infile) || die($@);

# do 4 sheets
for (my $sheet = 0; $sheet<4; $sheet++) {
	my $row = $startingrow;
	my $col = $startingcol;
	my $worksheet = $template->worksheet(0);
	
	# For each entry
	for (my $i = 0; $i<$total; $i++) {
		
		my $num1;
		my $num2;
		my $answer;
		
		# ADDITION
		if ($sheet == 0 ) {
			$num1 = round(rand()*20+1);
			$num2 = round(rand()*$num1);			
			$answer = $num1 + $num2;
		}
		
		# SUBTRACTION
		if ($sheet == 1 ) {
			$num1 = round(rand()*20+1);
			$num2 = round(rand()*$num1);
			$answer = $num1 - $num2;
		}

		# MULTIPLICATION		
		if ($sheet == 2 ) {
			$num1 = round(rand()*9+1);
			$num2 = round(rand()*$num1);
			$answer = $num1 * $num2;
		}
		
		# DIVISION		
		if ($sheet == 3 ) {
			$num2 = round(rand()*9)+1;
			$num1 = $num2 * round(rand()*$num2);
			$answer = $num1 / $num2;			
		}
	
	
		# Write data to some cells
		my $format1   = $template->{Worksheet}[$sheet]->{Cells}[$row][$col]->{FormatNo};
		my $format2   = $template->{Worksheet}[$sheet]->{Cells}[$row+1][$col]->{FormatNo};
		my $format3   = $template->{Worksheet}[$sheet]->{Cells}[$row+2][$col]->{FormatNo};

		# Print sheets without answers
		$template->AddCell($sheet, $row,   $col, $num1, $format1);
		$template->AddCell($sheet, $row+1, $col, $num2, $format2);

		# Print sheets with answers
		$template->AddCell($sheet+4, $row,   $col, $num1, $format1);
		$template->AddCell($sheet+4, $row+1, $col, $num2, $format2);
		$template->AddCell($sheet+4, $row+2, $col, $answer, $format3);
		
		# GO TO THE NEXT ROW
		$row+=$rowsep;
		
		# GO TO THE NEXT COLUMN AFTER 10 ROWS
		if (($i+1)%$entries_per_row == 0) {
			$col+=$colsep;
			$row = $startingrow;
		}
	}
}

my $workbook;
{
    # SaveAs generates a lot of harmless warnings about unset
    # Worksheet properties. You can ignore them if you wish.
    local $^W = 0;

    # Rewrite the file or save as a new file
    $workbook = $template->SaveAs($outfile);
}

$workbook->close();