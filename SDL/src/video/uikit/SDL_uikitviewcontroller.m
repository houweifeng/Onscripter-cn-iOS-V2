/*
  Simple DirectMedia Layer
  Copyright (C) 1997-2012 Sam Lantinga <slouken@libsdl.org>

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
*/
#include "SDL_config.h"

#if SDL_VIDEO_DRIVER_UIKIT

#include "SDL_video.h"
#include "SDL_assert.h"
#include "SDL_hints.h"
#include "../SDL_sysvideo.h"
#include "../../events/SDL_events_c.h"

#include "SDL_uikitviewcontroller.h"
#include "SDL_uikitvideo.h"
#include "SDL_uikitmodes.h"
#include "SDL_uikitwindow.h"


@implementation SDL_uikitviewcontroller

@synthesize window;

- (id)initWithSDLWindow:(SDL_Window *)_window
{
    self = [self init];
    if (self == nil) {
        return nil;
    }
    self.window = _window;

    return self;
}

- (void)loadView
{
    // do nothing.
}

- (void)viewDidLayoutSubviews
{
    extern int btnIsFull;
    
    if (self->window->flags & SDL_WINDOW_RESIZABLE) {
        extern int btnIsFull;
        SDL_WindowData *data = self->window->driverdata;
        UIWindow *uiwindow = data->uiwindow;
        const CGSize size = data->view.bounds.size;
        SDL_VideoDisplay *display = SDL_GetDisplayForWindow(self->window);
        SDL_DisplayModeData *displaymodedata = (SDL_DisplayModeData *) display->current_mode.driverdata;
        
        int w, h;
        
        w = (int)(size.width * displaymodedata->scale);
        h = (int)(size.height * displaymodedata->scale);
        
        

        
        SDL_SendWindowEvent(self->window, SDL_WINDOWEVENT_RESIZED, w, h);
    }
    if (btnIsFull) {
        SDL_WindowData *data = self->window->driverdata;
        UIWindow *uiwindow = data->uiwindow;
        const CGSize size = data->view.bounds.size;
        SDL_VideoDisplay *display = SDL_GetDisplayForWindow(self->window);
        SDL_DisplayModeData *displaymodedata = (SDL_DisplayModeData *) display->current_mode.driverdata;
        int w, h;
        
        w = (int)(size.width * displaymodedata->scale);
        h = (int)(size.height * displaymodedata->scale);
        
      //  [data->view removeFromSuperview];
        [onsScrollView release];
        [data->view setBounds:CGRectMake(0, 0,w,w/4.0*3 )];
        [data->view setCenter:CGPointMake(w/2, h/2)];
        
         [data->view updateFrame];
        
        CGRect frame = CGRectMake(0, 0, h, w);
        onsScrollView = [[ONS_scrollView alloc]initWithRectAndViewAndOri:frame :data->view :0];

        
        [uiwindow addSubview:onsScrollView->onsScrollView];
        SDL_SendWindowEvent(self->window, SDL_WINDOWEVENT_RESIZED, w, h);
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    NSUInteger orientationMask = 0;
    
    const char *orientationsCString;
    if ((orientationsCString = SDL_GetHint(SDL_HINT_ORIENTATIONS)) != NULL) {
        BOOL rotate = NO;
        NSString *orientationsNSString = [NSString stringWithCString:orientationsCString
                                                            encoding:NSUTF8StringEncoding];
        NSArray *orientations = [orientationsNSString componentsSeparatedByCharactersInSet:
                                 [NSCharacterSet characterSetWithCharactersInString:@" "]];
        
        if ([orientations containsObject:@"LandscapeLeft"]) {
            orientationMask |= UIInterfaceOrientationMaskLandscapeLeft;
        }
        if ([orientations containsObject:@"LandscapeRight"]) {
            orientationMask |= UIInterfaceOrientationMaskLandscapeRight;
        }
        if ([orientations containsObject:@"Portrait"]) {
            orientationMask |= UIInterfaceOrientationMaskPortrait;
        }
        if ([orientations containsObject:@"PortraitUpsideDown"]) {
            orientationMask |= UIInterfaceOrientationMaskPortraitUpsideDown;
        }
        
    } else if (self->window->flags & SDL_WINDOW_RESIZABLE) {
        orientationMask = UIInterfaceOrientationMaskAll;  // any orientation is okay.
    } else {
        if (self->window->w >= self->window->h) {
            orientationMask |= UIInterfaceOrientationMaskLandscape;
        }
        if (self->window->h >= self->window->w) {
            orientationMask |= (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
        }
    }
    
    // Don't allow upside-down orientation on the phone, so answering calls is in the natural orientation
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        orientationMask &= ~UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    return orientationMask;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orient
{
    NSUInteger orientationMask = [self supportedInterfaceOrientations];
    return (orientationMask & (1 << orient));
}

@end

#endif /* SDL_VIDEO_DRIVER_UIKIT */

/* vi: set ts=4 sw=4 expandtab: */
