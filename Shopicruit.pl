#!/usr/bin/perl  
use LWP::Simple qw( get );
use JSON qw( decode_json );

#Read from url
my $url = 'http://shopicruit.myshopify.com/products.json';
my $content = get $url;
die "Error getting url" unless defined $content;
my $data = decode_json $content;
my @data_array = $data->{products};
my @item_hash; 

#Retain all items that is a computer or a keyboard
foreach my $item ( @{$data_array[0]} ) {
	if ( $item->{title} =~ /computer|keyboard/i ) {
		my @variants = $item->{variants};
		
		foreach my $variant ( @{$variants[0]} ) {
			push @item_hash, { title => $item->{title}, grams => $variant->{grams}, price => $variant->{price} }; 
		}
	}
}

#Order weight (grams) from least to largest 
my @sortedby_grams = sort { $a->{grams} <=> $b->{grams} } @item_hash;
my $item_size = @sortedby_grams; 
my @items_bought = (); 
my ($item_count, $total_grams, $total_price) = (0, 0, 0);

#Keep adding next lightest item until weight limit is reached 
while ( $item_count < $item_size && ($total_grams + $sortedby_grams[$item_count]->{grams} < 100000) ){
	$total_grams += $sortedby_grams[$item_count]->{grams};
	$total_price += $sortedby_grams[$item_count]->{price};
	push @items_bought, $sortedby_grams[$item_count];
	$item_count++;
}

print "You will have to carry ${\scalar(@items_bought)} item(s) which will weigh @{[$total_grams/1000]} kg and it will cost you $total_price dollars!";