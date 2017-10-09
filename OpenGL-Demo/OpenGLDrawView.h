//
//  OpenGLDrawView.h
//  OpenGL-Demo
//
//  Created by user on 2017/9/6.
//  Copyright © 2017年 user. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <OpenGLES/EAGL.h>

@interface OpenGLDrawView : UIView

/*
 窗口宽度
 */
@property (nonatomic, assign) GLint width;
/*
 窗口高度
 */
@property (nonatomic, assign) GLint height;
/*
 渲染缓冲区
 */
@property (nonatomic, assign) GLuint viewRenderBuffer;
/*
 帧缓冲区
 */
@property (nonatomic) GLuint viewFrameBuffer;
/*
 深度缓冲区
 */
@property (nonatomic) GLuint depthRenderBuffer;
/*
 EAGLContext对象
 */
@property (nonatomic, strong) EAGLContext *context;

- (void)layoutSubviews;

@end
