#!/usr/bin/env perl

use strict;
use warnings;

use Benchmark qw/cmpthese timethese/;
use Koha::Holds;

use XML::LibXSLT;
use XML::LibXML;
use XML::LibXML::XPathContext;
my $hold = Koha::Holds->find( 2405 );

my $store =q{

    <xsl:template match="/">
                  <xsl:text>ftp://</xsl:text>
            <xsl:apply-templates/>
                  <xsl:text>ftp://</xsl:text>
    </xsl:template>
};

my $xslt = XML::LibXSLT->new();
#my $source = XML::LibXML->load_xml({string=>$record});
my $filename = '/kohadevbox/koha/handy/dumb.marcxml';
my $source = XML::LibXML->load_xml(location => $filename);
my $xpc = XML::LibXML::XPathContext->new($source);
$xpc->registerNs('marc',  'http://www.loc.gov/MARC21/slim');


my ($leader) = $xpc->findnodes('//marc:*[@tag=001]'); 
warn Data::Dumper::Dumper( $leader->to_literal()  );
warn Data::Dumper::Dumper( $xpc->findnodes('//marc:controlfield') );
#my @titles = $xpc->findnodes('//marc:datafield[@tag=245]/marc:subfield[@code="a"]');
        my @titles = $xpc->findnodes('//marc:datafield[@tag=245]');
        my @values;
        foreach my $tit (@titles){
            push @values, grep { $_->to_literal } $tit->findnodes('./subfield[@code="a"]');
warn Data::Dumper::Dumper( 
#        $tit->to_literal 
        \@values
        );
        }
die "kittens";

my $style_doc = XML::LibXML->load_xml(string => q{
        <xsl:stylesheet version="1.0"
          xmlns:marc="http://www.loc.gov/MARC21/slim"
          xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
          xmlns:str="http://exslt.org/strings"
          exclude-result-prefixes="marc str">
          
          <xsl:import href="/kohadevbox/koha/koha-tmpl/intranet-tmpl/prog/en/xslt/MARC21slimUtils.xsl"/>

    <xsl:template match="/">
                  <xsl:text>ftp://</xsl:text>
            <xsl:apply-templates/>
                  <xsl:text>ftp://</xsl:text>
    </xsl:template>

          <xsl:template match="marc:record">
                  <xsl:text>ftp://</xsl:text>
                  <xsl:if test="marc:datafield[@tag=245]">
              <xsl:for-each select="marc:datafield[@tag=245]">
              <xsl:call-template name="subfieldSelect">
              <xsl:with-param name="codes">a</xsl:with-param>
              </xsl:call-template>
                  <xsl:for-each select="subfield[@code=a]">
                  <xsl:text>ftp://</xsl:text>
                      <xsl:value-of select="."/>
                 </xsl:for-each>
                 </xsl:for-each>

                  <xsl:text>ftp://</xsl:text>
</xsl:if>
          </xsl:template>
        </xsl:stylesheet>
});

my $stylesheet = $xslt->parse_stylesheet($style_doc);

warn Data::Dumper::Dumper( $source->findnodes(q{datafield[@tag='245']/subfield[@code='a']})->get_nodelist() );
#foreach my $title ($source->getElementsByTagName('datafield') ){
#    warn $title->to_literal;
#    warn "yo";
#}
#foreach my $title ($source->findnodes('//@tag') ){
#    foreach my $sub ($title->findnodes('/') ){
#    warn $title->to_literal;
#    warn "yo";
#    }
#}

my $results = $stylesheet->transform($source);
#warn Data::Dumper::Dumper($source->toString);
#warn Data::Dumper::Dumper($style_doc->toString);
#warn $results->toString;
warn Data::Dumper::Dumper( $stylesheet->output_as_chars($results) );
