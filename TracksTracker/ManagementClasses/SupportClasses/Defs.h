/*
//  Defs.h
//  InfoReadTest
//
//  Represents the current properties in a track. Here so we
//  can minimize slow string compares everytime we want a component
//  of the track.
//
//  Created by jbehrbaum on 12/7/13.
//  Copyright (c) 2013 Jeff Behrbaum. All rights reserved.
*/

#pragma once


typedef enum
{
	INVALID_TRK_PROPERTY = -1,
	TRACK_ID,
	ARTWRK_URL_60,
	ARTWRK_URL_512,
	PRICE,
	ARTIST_NAME,
	TRACK_NAME,
	TRACK_VERSION,
	TRACK_DESC
}TRACK_PROPERTIES;

typedef enum
{
	BY_DEFAULT,
	BY_ID_ASCENDING,
	BY_ID_DESCENDING,
	BY_PRICE_ASCENDING,
	BY_PRICE_DESCENDING,
	BY_TRKNAME_ASCENDING,
	BY_TRKNAME_DESCENDING,
	BY_ARTISTNAME_ASCENDING,
	BY_ARTISTNAME_DESCENDING
}SORT_OPTIONS;