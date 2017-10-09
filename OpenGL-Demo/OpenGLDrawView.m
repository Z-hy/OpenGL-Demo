//
//  OpenGLDrawView.m
//  OpenGL-Demo
//
//  Created by user on 2017/9/6.
//  Copyright © 2017年 user. All rights reserved.
//

#import "OpenGLDrawView.h"

typedef struct {
    GLuint program;
    GLint  width;
    GLint  height;
} OpenGLESContext;

@interface OpenGLDrawView () {
    OpenGLESContext _openGLESContext;
}

@end

@implementation OpenGLDrawView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        CAEAGLLayer *caEaglLayer = (CAEAGLLayer *)self.layer;
        caEaglLayer.opaque = YES;
        caEaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        //EAGLContext对象管理着渲染信息、命令以及需要渲染的资源
        self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if (!self.context || ![EAGLContext setCurrentContext:self.context]) {
            return nil;
        }
        if (![self setOpenGLESContext]) {
            NSLog(@"setOpenGLESContext failed!");
        }
    }
    return self;
}


- (void)createFrameBuffer {
    //创建一个帧缓冲区
    glGenFramebuffers(1, &_viewFrameBuffer);
    //创建一个渲染缓冲区
    glGenFramebuffers(1, &_viewRenderBuffer);
    //绑定帧缓冲区到管线上
    glBindFramebuffer(GL_FRAMEBUFFER, _viewFrameBuffer);
    //绑定渲染缓冲区到管线上
    glBindFramebuffer(GL_RENDERBUFFER, _viewRenderBuffer);
    //为渲染缓冲区分配空间
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    //将渲染缓冲区与帧缓冲期进行绑定
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _viewRenderBuffer);
    //得到当前渲染窗口的宽度信息
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_width);
    //得到当前渲染窗口的高度信息
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_height);
    //创建一个深度缓冲区
    glGenRenderbuffers(1, &_depthRenderBuffer);
    //绑定深度缓冲区到管线上
    glBindFramebuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    //为深度缓冲区分配空间
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _width, _height);
    //将深度缓冲区与帧缓冲区进行绑定
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);
    //检查缓冲区状态是否完整
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"failed to create frame buffer!!!");
    }
}

- (void)destroyFrameBuffer {
    //删除帧缓冲器对象
    glDeleteBuffers(1, &_viewFrameBuffer);
    _viewFrameBuffer = 0;
    //删除渲染缓冲区对象
    glDeleteBuffers(1, &_viewRenderBuffer);
    _viewRenderBuffer = 0;
    //删除深度缓冲区对象
    if (_depthRenderBuffer) {
        glDeleteBuffers(1, &_depthRenderBuffer);
        _depthRenderBuffer = 0;
    }
    
}

- (BOOL)setOpenGLESContext {
    //vertex shader source
    GLbyte vertexShaderStr[] =
        "uniform mat4 u_mvpMatrix;      \n"
        "attribute vec4 vertextPosition;     \n"
        "void main()               \n"
        "{                         \n"
        "    gl_Position = vertextPosition;     \n"
        "}                         \n";
    
    //fragment shader source
    GLbyte fragmentShaderStr[] =
        "precision mediump float;\n"
        "void main()                                   \n"
        "{                                             \n"
        "   gl_FragColor = vec4 (0.0, 0.0, 1.0, 1.0);  \n"
        "}                                             \n";
    
    //vertext shader
    GLuint vertexShader;
    //fragment shader
    GLuint fragmentShader;
    //program
    GLuint program;
    //linked state
    GLint linked;
    
    //顶点着色器
    vertexShader = [self loadshader:(const char *)vertexShaderStr type:GL_VERTEX_SHADER];
    //片元着色器
    fragmentShader = [self loadshader:(const char *)fragmentShaderStr type:GL_FRAGMENT_SHADER];
    program = glCreateProgram();
    //创建失败，直接返回NO
    if (program == 0) {
        return NO;
    }
    
    //将顶点着色器添加到程序中
    glAttachShader(program, vertexShader);
    //将片元着色器添加到程序中
    glAttachShader(program, fragmentShader);
    //为每个顶点属性指定一个索引
    glBindAttribLocation(program, 0, "vertexPosition");
    //连接program
    glLinkProgram(program);
    //获取链接状态
    glGetProgramiv(program, GL_LINK_STATUS, &linked);
    
    //linked failed 直接返回GL_FALSE
    if (!linked) {
        GLint infoLen = 0;
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &infoLen);
        if (infoLen > 1) {
            char *infoLog = malloc(sizeof(char) * infoLen);
            glGetProgramInfoLog(program, infoLen, NULL, infoLog);
            free(infoLog);
        }
        glDeleteProgram(program);
        return GL_FALSE;
    }
    
    //保存program值
    _openGLESContext.program = program;
    //指定color buffer 的清除值，只有调用glClear(GL_COLOR_BUFFER_BIT) 时才真正清除color buffer
    glClearColor(1.0f, 0.0f, 0.0f, 0.0f);
    return YES;
}

- (GLuint)loadshader:(const char *)shaderSource type:(GLenum)type {
    GLuint shader;
    GLint compiled;
    
    //创建着色器
    shader = glCreateShader(type);
    if (shader == 0) {
        return 0;
    }
    //将着色器代码附加到着色器对象上
    glShaderSource(shader, 1, &shaderSource, NULL);
    //编译着色器
    glCompileShader(shader);
    //检查是否编译成功
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
    if (!compiled) {
        GLint infoLen = 0;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLen);
        if (infoLen > 1) {
            char *infoLog = malloc(sizeof(char) * infoLen);
            glGetShaderInfoLog(shader, infoLen, NULL, infoLog);
            free(infoLog);
        }
        glDeleteShader(shader);
        return 0;
    }
    return shader;
}

- (void)drawView {
    //将context设置为当前的EAGLContext
    [EAGLContext setCurrentContext:self.context];
    //绑定帧缓冲区到管线上
    glBindFramebuffer(GL_FRAMEBUFFER, _viewFrameBuffer);
    //给OpenGLESContext中的width、height变量赋值
    _openGLESContext.width = _width;
    _openGLESContext.height = _height;
    //顶点数组
    GLfloat vVertices[] = {
        0.0f, 0.5f, 0.0f,
        -0.5f, -0.5f, 0.0f,
        0.5f, -0.5f, 0.0f
    };
    //定义视口大小
    glViewport(0, 0, _openGLESContext.width, _openGLESContext.height);
    //清除color buffer
    glClear(GL_COLOR_BUFFER_BIT);
    //使用创建项目的program
    glUseProgram(_openGLESContext.program);
    //传入顶点数组中的数据
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, vVertices);
    //Enable顶点数组
    glEnableVertexAttribArray(0);
    //GL_TRIANGLES是以每三个顶点绘制一个三角形
    glDrawArrays(GL_TRIANGLES, 0, 3);
    //绑定渲染缓冲区到管线上
    glBindRenderbuffer(GL_RENDERBUFFER, _viewRenderBuffer);
    //提交渲染
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)layoutSubviews {
    //调用父类的layoutSubviews
    [super layoutSubviews];
    //销毁FrameBuffer
    [self destroyFrameBuffer];
    //创建FrameBuffer
    [self createFrameBuffer];
    //绘制
    [self drawView];
}

@end
